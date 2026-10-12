# Build Plan: <title>

**Spec:** ./spec.md
**Design:** ./design.md
**Review tier:** <1 critical | 2 high | 3 standard | 4 low>

> Committed **before** implementation starts. At merge time the plan and the diff
> should match; unexplained divergence is a review finding.
>
> A good phase is independently verifiable — at the end of it, something runs and you
> can tell whether it worked.

## Phase 1 — <name>

**Goal:** <one line: what exists when this is done>
**Detail:** ./build/01-<slug>.md
**Done test:** `<the exact command or check that proves this phase works>`

- [ ] <task>
- [ ] <task>
- [ ] Tests written and passing
- [ ] Done test passes

## Phase 2 — <name>

**Goal:**
**Detail:** ./build/02-<slug>.md
**Done test:** `<command>`

- [ ] <task>
- [ ] Tests written and passing
- [ ] Done test passes

## Cross-cutting

- [ ] `CLAUDE.md` updated if conventions, commands, or architecture changed
- [ ] Dependency manifests updated, versions pinned, committed
- [ ] Migration tested forward **and** backward
- [ ] Security tests written for Tier 1 paths
- [ ] Docs / runbook updated
- [ ] No debug output, commented-out tests, or TODOs standing in for requirements

## Impact check

Every file or symbol this plan creates, modifies or deletes, checked **live**. A note never
shortens this.

**Tool:** `<impactTool.command>` at `<revision>` — or **`tool-less`** (live search only;
lower confidence)

| Changed path / symbol | Dependents found | Blind spots searched | Notes |
|---|---|---|---|
| | | | |

**Ratchet:** <track or review tier raised? why — or "unchanged". Never lowered.>

*Say "nothing found by <tool and searches>" — never "there is nothing".*

## Knowledge used

Omit this section when code knowledge is not enabled for the repo. Format and rules:
`templates/code-knowledge.md`.

- <area>: fresh | partial | stale | missing | unverified — used / re-verified in part /
  ignored, and why

**Notes written or updated:** <areas, or none>

**Effort (self-reported — indicative, not proof):**

| | Files read | Searches | Tool runs |
|---|---|---|---|
| Consult + trace | | | |
| Impact check | | | |

**Friction:** <none, or `knowledge-misled` entries: note, claim, what happened, correction>

## Risks during build

| Risk | Mitigation | Trigger to stop and ask |
|---|---|---|
| | | |

## Plan amendments

<Log changes made during build, with the reason. The plan is living, but it changes
deliberately and visibly.>

| Date | Change | Why |
|---|---|---|
| | | |
