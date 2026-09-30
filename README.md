# spec-sdlc-simple

A spec-driven SDLC you can add to any repo. Nine stages, one named artifact per stage,
committed to version control. The artifact is the handoff.

Ships as a Claude Code plugin so each stage triggers without being asked, and as
[`SPEC_SDLC.md`](SPEC_SDLC.md) — one self-contained file that works with any agent.

Based on Anthropic's [AI-Native SDLC Playbook](https://claude.com/blog/the-ai-native-sdlc-playbook).

---

## The idea

The bottleneck in AI-assisted development is no longer writing code. It's knowing
whether the code being written is the right code. So intent and requirements move to
the front, into durable files, and a stage can't start until the previous one's
artifact exists.

| # | Stage | Artifact | Skill |
|---|-------|----------|-------|
| 1 | Intent | `intent.md` — the problem, before anyone solutions it | `/sdlc:intent` |
| 2 | Requirements | `spec.md` — functional, security, governance, stack, testing, local dev, CI/CD | `/sdlc:requirements` |
| 3 | Design | `design.md` — flows, screens, every state, copy, accessibility | `/sdlc:design` |
| 4 | Plan | `BUILD_PLAN.md` + `build/NN-*.md` | `/sdlc:plan` |
| 5 | Build | Code + ticked checkboxes, self-verified per phase | `/sdlc:build` |
| 6 | Test | `TEST_REPORT.md` — evidence per acceptance criterion | `/sdlc:test` |
| 7 | Deploy | A pull request. **The AI never merges it.** | `/sdlc:deploy` |
| 8 | Maintain | Production feedback becomes a new `intent.md` | `/sdlc:intent` |

Stages 1–8 ship a feature. One more acts on the process itself:

| Stage | What it does | Skill |
|---|---|---|
| 9 — Retro | Improves the skills, gated by a change advisory board | `/sdlc:retro` |

Three size tracks keep it proportionate — a typo fix doesn't get a nine-stage pass.

---

## How it's distributed

The process is a **gitignored clone inside your repo**, not copied files:

```
your-product-repo/
  .claude/skills/sdlc/       ← gitignored: the process, a git clone
  .claude/spec-sdlc.json     ← committed: which process version this repo runs
  CLAUDE.md                  ← yours, never synced
  REVIEW.md                  ← yours, never synced
  specs/0001-*/              ← yours, never synced
```

That split is the whole design. `CLAUDE.md`, `REVIEW.md` and `specs/` hold *this
repo's* knowledge and must not sync. The process is a clone, so it updates with a pull
instead of drifting. And because an in-place plugin has no version identity Claude
Code records, the committed lock file is the only thing that says which process version
produced a given pull request — which is what makes the audit trail work.

Two branches:

| Branch | Purpose |
|---|---|
| `main` | Development. Retro pull requests land here. |
| `release` | What product repos clone. **A merge into it is a board decision**, made by a human. |

So a repo only ever runs process that has been approved.

---

## Setup

### 1. Clone the process

```bash
git clone -b release https://github.com/wodutoit/spec-sdlc-simple .claude/skills/sdlc
```

PowerShell is the same command — `git` handles the path.

### 2. Trust the workspace

Restart Claude Code from the **repository root** and accept the trust dialog. A
project-scope skills-directory plugin isn't loaded until the workspace is trusted. Then
`/reload-plugins`, or just relaunch.

Check it worked:

```bash
claude plugin list
```

You want `sdlc@skills-dir` with `Status: ✔ enabled`. If you instead see *"not loaded
because this workspace was not trusted"*, the trust dialog hasn't been accepted yet.

### 3. Bootstrap

```
/sdlc:bootstrap
```

It gitignores the clone, asks your team a few questions (retro cadence, protected
branches, your one test command, default review tier), writes the lock file, and seeds
`CLAUDE.md` and `REVIEW.md`.

### 4. Turn on branch protection

Protect `main`: require a pull request and code-owner approval.

The plugin ships a hook that blocks `gh pr merge`, `git merge`, force pushes,
protected-branch pushes and `--no-verify`. **That is a backstop, not the control.** It
only holds where it's installed; branch protection holds everywhere. Do both, and if
you only do one, do this one.

---

## Staying current

```
/sdlc:bootstrap --relock
```

Pulls the release branch and updates the lock in one action, so the two can't drift.
Use `--reconfigure` to change the per-repo answers without touching the lock.

You don't have to remember: a `SessionStart` hook tells you when the process is behind,
when the lock is stale, or — loudly — when the clone is on a branch that was never
approved for release.

---

## Improving the process

`/sdlc:retro` reads the evidence your own artifacts generate — plan amendment logs,
recurring "Not covered" entries, findings that keep reappearing, gates that keep being
skipped — and turns patterns into a proposal.

It works in a git worktree, never editing the process while it's running, then hands the
board three things together: a recommendation document with cited evidence, the actual
diff, and eval results showing existing behaviour still holds. Board approval is the
`main` → `release` merge, performed by a human.

Rollback is reverting that merge.

---

## Without Claude Code

[`SPEC_SDLC.md`](SPEC_SDLC.md) is the entire process in one file, with every artifact
template inline. Drop it in, point any agent at it, done — no plugin, no clone, no
updates.

```bash
curl -O https://raw.githubusercontent.com/wodutoit/spec-sdlc-simple/release/SPEC_SDLC.md
```

You lose automatic stage triggering, the merge hook, the staleness check and the retro
loop. You keep the process.

---

## What's in here

```
SPEC_SDLC.md              The process in one self-contained file
SKILL.md                  The router — works out which stage you're in
CHANGELOG.md              One entry per board-approved release. Read before relocking.
CONTRIBUTING.md           How to work on the process, and what was learned building it

.claude-plugin/plugin.json
skills/                   intent, requirements, design, plan, build, test, deploy,
                          retro, bootstrap
hooks/hooks.json          Wires both hooks — nothing to install by hand
scripts/
  block-merge.sh          Blocks merges, force pushes, protected-branch pushes
  check-staleness.sh      Reports drift between the lock and the clone
templates/                7 artifact skeletons, plus CLAUDE.md / REVIEW.md / settings.json
evals/                    Regression guard — see evals/README.md
retro/                    Retro recommendations, one per board proposal
```

---

## Adopting gradually

Don't switch all nine stages on at once. Stages are ordered by dependency and Intent
has no prerequisites.

1. Set up, write one real `intent.md`. See how it feels.
2. `CLAUDE.md` — fastest payoff here, and cheap.
3. Stage 2 on your next real feature. Most of the value is here.
4. Stage 4 — `BUILD_PLAN.md` committed *before* the code.
5. Branch protection.
6. Stages 6 and 7, then `REVIEW.md`.
7. Stage 8 once you have monitoring worth reacting to; stage 9 once you have enough
   artifacts to find patterns in.

**Working:** less rework after build starts, higher first-pass merge rate, fewer
"that's not what I meant" moments.

**Failing:** artifacts written after the code as paperwork, everything tracked L,
everything tracked S, specs nobody reads. All the same failure — the artifact stopped
being the handoff and became a formality.

---

## Notes

- **Context cost.** Ten skills add roughly 700 tokens to every session where the plugin
  is enabled, used or not. `claude plugin details sdlc` gives the current figure.
- **Non-interactive sessions.** `-p` and SDK sessions never accept the trust dialog, so
  the plugin doesn't auto-load there. Pass
  `--plugin-dir .claude/skills/sdlc` to load it explicitly in CI.
- **Organizational standards.** Stage 2 is where a standards or compliance check
  belongs — before code exists, not at review time. `spec.md` §3 and §4 carry a line
  for the reference.
- The playbook collapses requirements and design into one stage; this splits them into
  Requirements, Design and Plan, because in practice they have different participants
  and fail in different ways. Artifact names match the playbook where they map.

## Licence

MIT.
