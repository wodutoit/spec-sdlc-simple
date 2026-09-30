---
name: retro
description: Stage 9 of the spec-driven SDLC — improve the process itself. Use when the user wants a process retrospective, says a stage or gate isn't working, asks to improve the SDLC skills, or wants to propose a process change for CAB. Gathers evidence from the repo's own artifacts, writes a recommendation, edits the skills in a worktree, runs evals, and opens a PR. Never merges.
---

# Stage 9 — Retro

Improves **the process**, not the product. Stages 1–8 ship a feature; this one ships a
change to how features get shipped.

A skill edit changes behaviour in every repo running this process. By the process's own
tiering that is closer to Tier 1 than Tier 3 — which is why it produces evidence, not
just an opinion, and why CAB gates the release rather than you.

## First: do not edit the running process in place

The clone at `.claude/skills/sdlc/` is checked out on `release` **and is the code
currently executing**. Checking out a branch there would swap the running process
mid-session. Work in a worktree instead:

Name the branch and report after **the product repo**, not just the date. Two teams
running retros in the same week would otherwise collide on an identical filename:

```bash
git -C .claude/skills/sdlc fetch origin main
git -C .claude/skills/sdlc worktree add ../../sdlc-retro-<date> -b retro/<date>-<product-repo>-<slug> origin/main
```

That puts an editable checkout at `.claude/sdlc-retro-<date>/` (gitignored by
bootstrap) while the live checkout stays on `release`, untouched. Confirm the live
checkout's SHA before and after — it must not change.

Branch off `origin/main`, never off `release`. `release` is CAB's.

## 1. Gather evidence

The process generates its own telemetry. Read it rather than asking how people felt:

| Source | What it tells you |
|---|---|
| `BUILD_PLAN.md` amendment logs | Where plans were wrong → stage 4's guidance is wrong |
| `TEST_REPORT.md` "Not covered" sections | The same gap recurring → spec §7 is missing a line |
| Review findings appearing 3+ times | Promote to a rule — `CLAUDE.md` or a skill |
| Stages skipped, artifacts missing | That gate is too expensive, or asks the wrong question |
| Track vs. actual effort | Started S, should have been L → track heuristics need work |
| Repeated stop-and-ask points | Ambiguity in a skill |

Cite specifics — file, feature, line. A finding without a citation is an opinion, and
CAB should reject it.

Look across `specs/*/` rather than one feature. One feature's quirk is not a process
problem; the same thing three times is.

## 2. Split findings by destination

Two buckets, and conflating them is how a shared process accumulates one team's quirks:

- **Repo-specific** → that repo's `CLAUDE.md`. Handle these directly, in the product
  repo, as an ordinary change.
- **Process-level** → the skills, upstream. These go through CAB.

If everything lands in the first bucket, say so and stop. A retro with no process
finding is a good outcome, not a failed one.

## 3. Write the recommendation

`retro/YYYY-MM-DD-<product-repo>-<slug>.md` **in the worktree**, from
`${CLAUDE_PLUGIN_ROOT}/templates/retro.md`. This is the document CAB reads, so fill in
the risk, affected-repos and rollback fields properly rather than leaving placeholders.

**Fill in "Repos reviewed" and "Process version reviewed" precisely.** The report lives
in the process repo, not the product repo, so those two fields are the only trace
linking this change back to the evidence that motivated it. Read the version from the
product repo's `.claude/spec-sdlc.json`.

## 4. Make the edits

In the worktree. Keep the diff as small as the finding justifies — a retro that
rewrites six skills is several changes pretending to be one, and CAB can't assess it.
Split into separate PRs instead.

## 5. Run the evals

```bash
cd .claude/sdlc-retro-<date> && claude plugin eval .
```

Paste the real output into the report. If evals fail, the change isn't ready — fix it.
If the suite doesn't cover the behaviour you just changed, **add a case**; that is part
of the change, not a follow-up.

**If the command doesn't exist** (`error: unknown command 'eval'` — it is absent on
Claude Code v2.1.177), say exactly that in the report's Evals section. Do not leave the
section blank or write anything that reads as if evals passed. CAB then decides whether
to accept the change without that evidence, which is their call, not yours.

## 6. Update `CHANGELOG.md`

In the same PR, so a team that pulls later can see what changed and why.

## 7. Open a PR into `main`

Description covers: the findings with citations, what changed, repos affected, eval
results, and a link to the report.

**Then stop.** You do not merge, and you do not merge `main` into `release`. CAB
approval *is* the `main` → `release` merge, and a human performs it.

## 8. Clean up

```bash
git -C .claude/skills/sdlc worktree remove ../../sdlc-retro-<date>
```

Only after the PR is open. Confirm the live checkout is still on `release` at its
original SHA.

## Gate

- Every finding cites specific evidence.
- Repo-specific and process-level findings separated.
- Report complete, including risk and rollback.
- Evals run, with real output recorded.
- `CHANGELOG.md` updated.
- PR open against `main`. Not merged. Live checkout unchanged.
