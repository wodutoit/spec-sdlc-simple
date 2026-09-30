---
name: bootstrap
description: Set up the spec-driven SDLC in a repo, update it after a release, or change its per-repo settings. Use when the user wants to add this process to a repo, asks to update or re-lock the process, says the process is out of date or behind, or wants to change the retro cadence, test command, or protected branches. Modes are fresh setup, --relock and --reconfigure.
---

# Bootstrap

Sets up — or re-locks — the spec-driven SDLC in a product repo.

## Prerequisite (the user does this, not you)

This skill only runs once the plugin is loaded, so cloning happens first:

```bash
git clone -b release <process-repo-url> .claude/skills/sdlc
```

Then **restart Claude Code and accept the workspace trust dialog**. A project-scope
skills-directory plugin is not loaded until the workspace is trusted, and `-p` or SDK
sessions never accept that dialog. After trusting, `/reload-plugins` or a relaunch
loads it.

If the user hasn't cloned yet, give them that command and stop. Don't try to work
around the trust step.

## Pick a mode

Check whether `.claude/spec-sdlc.json` exists in the project root.

| State | Argument | Do |
|---|---|---|
| No lock file | — | **Fresh setup** below |
| Lock exists | `--relock` | **Relock** below |
| Lock exists | `--reconfigure` | **Reconfigure** below |
| Lock exists | none | Explain both options and stop. Don't guess |

---

## Fresh setup

**1. Add to the product repo's `.gitignore`:**

```
.claude/skills/sdlc/
.claude/sdlc-retro-*/
```

The clone is gitignored deliberately — it is a separate repo with its own history.
The lock file below is what gives the product repo an audit record.

**2. Interview the team.** Use `AskUserQuestion`; don't assume defaults:

- **Retro cadence** — on demand / after each feature ships / monthly. Record it even
  when the answer is "on demand", because it may become formal later.
- **Protected branches** beyond `main`.
- **The one test command** and what its healthy output looks like — this feeds
  `CLAUDE.md` and spec §7, and without it stage 5 can't self-verify.
- **Default review tier** for this repo (1–4).

**3. Write `.claude/spec-sdlc.json`** — committed. This file is load-bearing: an
in-place plugin has no version identity that Claude Code records, so this lock is the
*only* evidence of which process version produced any given PR.

```json
{
  "repo": "<clone's origin url>",
  "branch": "release",
  "commit": "<full sha from: git -C .claude/skills/sdlc rev-parse HEAD>",
  "pulled": "<today, YYYY-MM-DD>",
  "config": {
    "retroCadence": "on-demand",
    "protectedBranches": ["main"],
    "testCommand": "make test",
    "healthyOutput": "...",
    "defaultReviewTier": 3
  }
}
```

Read the real values from the clone — never invent the SHA.

**4. Seed the repo-specific files.** These are per-repo by design and never sync:

- `CLAUDE.md` from `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md`. If one already
  exists, **merge a `## Process` section into it** rather than overwriting — that file
  usually holds real knowledge.
- `REVIEW.md` from `${CLAUDE_PLUGIN_ROOT}/templates/REVIEW.md`, with the review tier
  and protected branches filled in from the interview.

**5. Offer the permission entries.** `plugin.json` cannot carry permissions, so the
hook is the enforcement layer and these are belt-and-braces. Offer to merge
`${CLAUDE_PLUGIN_ROOT}/templates/settings.json`'s `permissions` block into the repo's
`.claude/settings.json`, preserving anything already there.

**6. State the branch-protection requirement plainly:**

> The merge-blocking hook is a backstop. Branch protection on `main` requiring a pull
> request and code-owner approval is the actual control, and it has to be set on the
> remote — I can't do it from here.

**7. Ask before committing.** Show what will be committed.

---

## Relock

The routine update path. One action, so the lock can never drift from the clone.

**Capture the old SHA before pulling** — afterwards it's gone, and without it you can
only show the user the whole changelog rather than what changed *for them*:

```bash
OLD=$(git -C .claude/skills/sdlc rev-parse HEAD)      # or read `commit` from the lock
git -C .claude/skills/sdlc pull
git -C .claude/skills/sdlc log --oneline "$OLD..HEAD"
git -C .claude/skills/sdlc diff "$OLD..HEAD" -- CHANGELOG.md
```

Then:

1. Summarise the delta from that diff — the releases this repo just crossed, not the
   full changelog. A team that skipped three releases needs to know all three.
2. Call out anything with a **Migration** line: those need action beyond relocking.
3. Rewrite `commit` and `pulled` in `.claude/spec-sdlc.json`. Leave `config` alone.
4. Tell the user to run `/reload-plugins` so the session picks up the new process.
5. Ask before committing.

If the pull brought nothing, say so and change nothing.

If the clone is on a branch other than the locked one, stop and say so — that means
unapproved process, and pulling would entrench it.

---

## Reconfigure

Re-run the interview only. Preserve `commit` and `pulled` exactly. Update `config`,
and propagate anything that changed into `CLAUDE.md` and `REVIEW.md`. Ask before
committing.

---

## Never

- Never commit without asking.
- Never write the clone path into git — it stays ignored.
- Never invent a commit SHA, an origin URL, or a test command. Read them or ask.
