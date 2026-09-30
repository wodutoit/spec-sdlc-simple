# Retro: <title>

**Date:** <YYYY-MM-DD>
**Author:** <name>
**Repos reviewed:** <which product repos' artifacts this draws on>
**Process version reviewed:** <commit from .claude/spec-sdlc.json>
**Proposed for:** `main` → CAB → `release`

> This is the document CAB reads. Every finding cites evidence; every proposed change
> names the file it touches. A finding without a citation is an opinion.

## Summary

<Three sentences. What is wrong with the process, what changes, and what risk that
carries.>

---

## Evidence

| # | Source | Observation | Occurrences |
|---|---|---|---|
| E1 | `specs/0004-invites/BUILD_PLAN.md` amendment log | <what it showed> | <n> |
| E2 | | | |

<Cite file and feature. Where something recurred, say how many times and where — one
occurrence is a quirk, three is a process problem.>

## Findings

### F1 — <short title>

**Evidence:** E1, E3
**Type:** process-level | repo-specific
**Stage affected:** <n>

<What the evidence means. Why the current guidance produces this outcome.>

---

## Proposed changes

Process-level only. Repo-specific findings are handled in their own repo's
`CLAUDE.md` and listed under [Handled locally](#handled-locally) below.

| # | File | Change | Addresses |
|---|---|---|---|
| C1 | `skills/plan/SKILL.md` | <what changes> | F1 |

### Rationale

<Why this change rather than the alternatives. What was rejected and why.>

### Alternatives rejected

| Option | Why not |
|---|---|
| | |

---

## Impact

**Repos affected:** <every repo tracking `release` — list them, or state the count>

**Behaviour change users will notice:**

**Review tier of this change:** <1–4, per `REVIEW.md`>

**Migration needed by consuming repos:** <none / re-lock only / something more>

---

## Risk

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| | | | |

**Blast radius:** a bad process change affects every repo on `release`, not one
feature.

**Rollback:** revert the `main` → `release` merge. Teams pick up the revert on their
next `/sdlc:bootstrap --relock`. State here if anything else is needed.

---

## Evals

**Command:** `claude plugin eval`

```
<real output — paste it, don't summarise>
```

**Cases added or changed for this proposal:** <which, and what behaviour they pin>

<If evals could not be run, say so plainly here and explain why. Do not leave this
section implying they passed.>

---

## Handled locally

Repo-specific findings that do **not** need CAB, and where they went.

| Finding | Repo | Landed in |
|---|---|---|
| | | |

---

## CAB decision

*Completed by CAB, not by the proposer.*

- **Decision:** approved / rejected / deferred
- **Date:**
- **Approvers:**
- **Conditions:**
- **Released as:** <`CHANGELOG.md` version / merge commit>
