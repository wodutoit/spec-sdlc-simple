#!/usr/bin/env bash
# Blocks merge operations and pushes to protected branches.
#
# Wired as a PreToolUse hook on Bash by hooks/hooks.json. Nothing to install by
# hand: it ships with the plugin.
#
# Exit 0 = allow. Exit 2 = block, and stderr is shown to the agent.
#
# This is a backstop, not the control. Branch protection on the remote is the
# control: it holds even when the agent runs somewhere this hook doesn't.

set -uo pipefail

PROTECTED_BRANCHES="main master release production"

# A repo can protect additional branches via "protectedBranches" in
# .claude/spec-sdlc.json. Deliberately a union with the defaults, never a
# replacement — config may add protection, never remove it.
LOCK="${CLAUDE_PROJECT_DIR:-.}/.claude/spec-sdlc.json"
if [ -f "$LOCK" ]; then
  extra=$(tr -d '\n' < "$LOCK" 2>/dev/null \
    | grep -o '"protectedBranches"[[:space:]]*:[[:space:]]*\[[^]]*\]' \
    | grep -o '"[^"]*"' | sed 's/"//g' | grep -v '^protectedBranches$' | tr '\n' ' ')
  for b in $extra; do
    case " $PROTECTED_BRANCHES " in
      *" $b "*) ;;
      *) PROTECTED_BRANCHES="$PROTECTED_BRANCHES $b" ;;
    esac
  done
fi

payload=$(cat)

# Extract the command. Prefer jq; fall back to a crude grep so a missing jq
# fails open on parsing rather than blocking all Bash calls.
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')
else
  cmd=$(printf '%s' "$payload" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')
fi

[ -z "$cmd" ] && exit 0

deny() {
  echo "BLOCKED by spec-driven SDLC (stage 7): $1" >&2
  echo "" >&2
  echo "The AI does not merge pull requests or push to protected branches." >&2
  echo "Open the PR and report the URL. A human makes the merge decision." >&2
  exit 2
}

# --- merge operations ---------------------------------------------------------
case "$cmd" in
  *"gh pr merge"*)            deny "'gh pr merge' — merging a pull request." ;;
  *"gh pr ready"*"--merge"*)  deny "auto-merge on a pull request." ;;
  *"--auto"*"merge"*)         deny "enabling auto-merge." ;;
  *"git merge"*)              deny "'git merge'." ;;
  *"git rebase"*"--onto"*main*) deny "rebasing onto a protected branch." ;;
esac

# gh api used to reach the merge endpoint
if printf '%s' "$cmd" | grep -Eq 'gh +api.*(/merge|pulls/[0-9]+/merge)'; then
  deny "'gh api' call to a merge endpoint."
fi

# --- pushes to protected branches --------------------------------------------
for branch in $PROTECTED_BRANCHES; do
  if printf '%s' "$cmd" | grep -Eq "git +push([^&|;]*)\\b(origin|upstream)?\\b[^&|;]*\\b${branch}\\b"; then
    deny "push to protected branch '${branch}'."
  fi
done

# --- force push --------------------------------------------------------------
if printf '%s' "$cmd" | grep -Eq 'git +push[^&|;]*(--force([^-]|$)|--force-with-lease|[[:space:]]-f([[:space:]]|$))'; then
  deny "force push."
fi

# --- skipping verification ---------------------------------------------------
if printf '%s' "$cmd" | grep -Eq '(--no-verify|--no-gpg-sign)'; then
  deny "bypassing commit hooks or signing. Fix the underlying failure instead."
fi

exit 0
