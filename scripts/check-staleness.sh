#!/usr/bin/env bash
# SessionStart hook. Compares the product repo's committed lock file against the
# process clone, and reports drift.
#
# Design constraints:
#   - Never blocks and never fails a session. Exits 0 on every path.
#   - Silent unless something is actually wrong.
#   - Fetches at most once a day, so session start stays fast.
#
# Output: JSON. `systemMessage` is shown to the user; `additionalContext` goes into
# Claude's context so it can act on the drift rather than ignore it.

set -uo pipefail

# Drain stdin. A hook that leaves it unread can stall the caller.
payload=$(cat 2>/dev/null || true)

# Exit quietly no matter what goes wrong from here on.
quiet_exit() { exit 0; }
trap quiet_exit ERR

CLONE="${CLAUDE_PLUGIN_ROOT:-}"
[ -n "$CLONE" ] && [ -d "$CLONE/.git" ] || quiet_exit
command -v git >/dev/null 2>&1 || quiet_exit

# Project root: the env var when present, else `cwd` from the event payload.
PROJECT="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$PROJECT" ]; then
  PROJECT=$(printf '%s' "$payload" \
    | tr ',' '\n' \
    | grep -m1 '"cwd"' \
    | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"//; s/"$//; s/\\\\/\//g')
fi
[ -n "$PROJECT" ] || quiet_exit

LOCK="$PROJECT/.claude/spec-sdlc.json"
# Not a bootstrapped repo. Say nothing.
[ -f "$LOCK" ] || quiet_exit

json_str() { # $1 = key -> prints the string value, or empty
  grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$LOCK" 2>/dev/null \
    | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//'
}

LOCK_BRANCH=$(json_str branch); LOCK_BRANCH=${LOCK_BRANCH:-release}
LOCK_COMMIT=$(json_str commit)

HEAD_COMMIT=$(git -C "$CLONE" rev-parse HEAD 2>/dev/null || true)
CUR_BRANCH=$(git -C "$CLONE" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
[ -n "$HEAD_COMMIT" ] || quiet_exit

# --- state 3 (most serious): running process that was never approved -----------
if [ -n "$CUR_BRANCH" ] && [ "$CUR_BRANCH" != "HEAD" ] && [ "$CUR_BRANCH" != "$LOCK_BRANCH" ]; then
  MSG="Process clone is on branch '$CUR_BRANCH' but this repo is locked to '$LOCK_BRANCH'. You are running process that has not been approved for release."
  CTX="The spec-driven SDLC clone at .claude/skills/sdlc is checked out on '$CUR_BRANCH', not the locked branch '$LOCK_BRANCH'. Tell the user their process is unapproved and offer to switch back with: git -C .claude/skills/sdlc checkout $LOCK_BRANCH"
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$MSG" "$CTX"
  exit 0
fi

# --- fetch, at most once a day ------------------------------------------------
STAMP_DIR="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}}"
STAMP="$STAMP_DIR/last-fetch"
NOW=$(date +%s 2>/dev/null || echo 0)
LAST=0
[ -f "$STAMP" ] && LAST=$(cat "$STAMP" 2>/dev/null || echo 0)
case "$LAST" in ''|*[!0-9]*) LAST=0 ;; esac
if [ "$NOW" -gt 0 ] && [ $((NOW - LAST)) -gt 86400 ]; then
  mkdir -p "$STAMP_DIR" 2>/dev/null || true
  if command -v timeout >/dev/null 2>&1; then
    timeout 20 git -C "$CLONE" fetch --quiet origin "$LOCK_BRANCH" 2>/dev/null || true
  else
    git -C "$CLONE" fetch --quiet origin "$LOCK_BRANCH" 2>/dev/null || true
  fi
  printf '%s' "$NOW" > "$STAMP" 2>/dev/null || true
fi

# --- state 1: clone is behind the approved branch ------------------------------
BEHIND=$(git -C "$CLONE" rev-list --count "HEAD..origin/$LOCK_BRANCH" 2>/dev/null || echo 0)
case "$BEHIND" in ''|*[!0-9]*) BEHIND=0 ;; esac
if [ "$BEHIND" -gt 0 ]; then
  MSG="Spec-driven SDLC process is $BEHIND commit(s) behind origin/$LOCK_BRANCH. Run /sdlc:bootstrap --relock to update."
  CTX="The SDLC process clone is $BEHIND commit(s) behind origin/$LOCK_BRANCH. Mention this once and offer to run /sdlc:bootstrap --relock, which pulls and updates the committed lock file together."
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$MSG" "$CTX"
  exit 0
fi

# --- state 2: lock no longer matches what is checked out -----------------------
if [ -n "$LOCK_COMMIT" ] && [ "$LOCK_COMMIT" != "$HEAD_COMMIT" ]; then
  MSG="Process lock file is stale: .claude/spec-sdlc.json records ${LOCK_COMMIT:0:12} but the clone is at ${HEAD_COMMIT:0:12}. Run /sdlc:bootstrap --relock."
  CTX="The committed lock at .claude/spec-sdlc.json records commit ${LOCK_COMMIT:0:12} but the clone is at ${HEAD_COMMIT:0:12}, so the repo has no accurate record of which process version it is running. Offer to run /sdlc:bootstrap --relock."
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$MSG" "$CTX"
  exit 0
fi

# In sync. Say nothing.
exit 0
