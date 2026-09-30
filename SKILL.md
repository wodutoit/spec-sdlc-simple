---
name: sdlc
description: Router for the spec-driven SDLC. Use when the user starts new work, asks "what stage am I in", "what's next", asks about the process, or begins a feature without a spec directory. Figures out the current stage from what exists on disk and routes to the right stage skill.
---

# Spec-Driven SDLC — router

Full process: `${CLAUDE_PLUGIN_ROOT}/SPEC_SDLC.md`. Read it if you need detail beyond
this.

## Stages

| # | Stage | Artifact | Skill |
|---|-------|----------|-------|
| 1 | Intent | `intent.md` | `/sdlc:intent` |
| 2 | Requirements | `spec.md` | `/sdlc:requirements` |
| 3 | Design | `design.md` | `/sdlc:design` |
| 4 | Plan | `BUILD_PLAN.md` + `build/NN-*.md` | `/sdlc:plan` |
| 5 | Build | code + ticked plan | `/sdlc:build` |
| 6 | Test | `TEST_REPORT.md` | `/sdlc:test` |
| 7 | Deploy | PR, never a merge | `/sdlc:deploy` |
| 8 | Maintain | new `intent.md` | `/sdlc:intent` |

Stages 1–8 ship a feature. Two skills sit outside that pipeline:

| Skill | Purpose |
|---|---|
| `/sdlc:bootstrap` | Set this process up in a repo, or re-lock it after a pull |
| `/sdlc:retro` | **Stage 9** — improve the process itself, via CAB |

## Work out where you are

1. `ls specs/` — which feature directories exist.
2. In the relevant one, the highest-numbered artifact present tells you the last
   completed stage. Missing artifact = that stage hasn't happened.
3. Check the **Track** line in `intent.md` — S, M, or L. It determines which stages
   are required:
   - **S** — stages 1, 5, 6, 7. Skip 2, 3, 4.
   - **M** — stages 1, 2, 4, 5, 6, 7. Skip 3 unless user-facing.
   - **L** — all stages.
4. Then invoke the skill for the next required stage.

## Starting new work

No `specs/` directory, or the user is describing something new: that's stage 1.
Invoke `/sdlc:intent`.

Do not skip ahead to code because the request sounds simple. Propose a track instead —
track S exists precisely so small things stay cheap.

## Non-negotiables at every stage

- The artifact is the handoff. No artifact, no stage completion.
- Ask before committing. Ask before opening a PR.
- **Never merge a pull request.** Not squash, not rebase, not auto-merge.
- Never weaken a test, mock away a security control, or suppress a scanner finding.
- Anything touching auth, authorization, secrets, payments, or personal data is
  track L regardless of size. Same for schema changes and public API contracts.

## Numbering a new feature

Four-digit sequence, next unused, plus a kebab-case slug: `specs/0007-user-invites/`.
Never renumber existing directories.
