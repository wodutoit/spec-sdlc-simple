# SPEC_SDLC.md — Spec-Driven SDLC

> **This file is self-contained.** An agent that reads it has everything needed to run
> the process, with no other tooling. In a Claude Code repo the same process ships as
> the `sdlc` plugin, which makes each stage trigger without being asked — see the
> [README](README.md) for setup.
>
> Based on Anthropic's [AI-Native SDLC Playbook](https://claude.com/blog/the-ai-native-sdlc-playbook).

---

## The rule

**Every product or feature moves through numbered stages. Each stage produces a named
artifact, committed to version control, before the next stage starts.**

The artifact *is* the handoff. Not a conversation, not a ticket, not someone's memory
of what was agreed. If the artifact doesn't exist, the stage isn't done.

This exists because the bottleneck in AI-assisted development is no longer writing
code — it's knowing whether the code being written is the right code. Front-loading
intent and requirements into durable files is what makes fast code generation safe.

---

## Stages at a glance

| # | Stage | Artifact | Who drives | Gate to advance |
|---|-------|----------|-----------|-----------------|
| 1 | **Intent** | `intent.md` | Originator + AI | Problem and outcome stated in one paragraph each; no solution detail |
| 2 | **Requirements** | `spec.md` | Product + team + AI | Every checklist section answered or marked N/A; **acceptance scenarios approved by a named person** |
| 3 | **Design** | `design.md` + `design/` artifacts | Design + AI | Artifact fidelity agreed; every screen/flow and state described; brand decisions resolved |
| 4 | **Plan** | `BUILD_PLAN.md` + `build/NN-*.md` | Engineer + AI | Phases independently verifiable; each has a stated done-test |
| 5 | **Build** | Code + checked-off plan | AI, engineer reviews | All phase checkboxes ticked; self-verification passing |
| 6 | **Test** | `TEST_REPORT.md` | AI, engineer reviews | Validated against the **approved** scenarios, none changed since; target met; evidence attached |
| 7 | **Deploy** | PR (never a merge) | AI proposes, human decides | Human approval on PR; **AI never merges** |
| 8 | **Maintain** | New `intent.md` | Monitoring / AI / anyone | Loops back to stage 1 |

Stage 8 closes the loop — an incident, a regression, or a support pattern becomes a
new `intent.md` and re-enters at stage 1. It is where the process stops being a
pipeline and becomes a cycle.

### Outside the pipeline

Stages 1–8 ship a feature. One stage acts on *the process itself* and does not
participate in that loop:

| Stage | Artifact | Who drives | Gate to advance |
|-------|----------|-----------|-----------------|
| **9 — Retro** | Recommendation + skill diff + eval results | Team | Change advisory board approves the release |

---

## Where artifacts live

One directory per feature, numbered, under `specs/`:

```
specs/
  0001-user-invites/
    intent.md            # stage 1
    spec.md              # stage 2
    design.md            # stage 3 — describes and indexes the artifacts below
    design/              # stage 3 — wireframes, mockups, prototype, brand, icons
      wireframes/
      mockups/
      brand/
      icons/
    BUILD_PLAN.md        # stage 4 — the phased checklist
    build/
      01-schema.md       # stage 4 — detailed build instructions per phase
      02-invite-api.md
      03-email-delivery.md
      04-accept-flow.md
    TEST_REPORT.md       # stage 6
```

Repo-level files that support the process:

```
CLAUDE.md                     # conventions, commands, architecture, how to verify
REVIEW.md                     # what a review checks and at what severity
.claude/spec-sdlc.json        # committed: which process version this repo runs
.claude/skills/sdlc/          # gitignored: the process itself, a clone
```

Those last two are the split that makes this work. `CLAUDE.md`, `REVIEW.md` and
`specs/` are **per-repo and never sync** — they hold this repo's own knowledge. The
process is a gitignored clone, so it updates with a pull instead of drifting. The
committed lock file is what records which version of the process any given pull
request was built under.

**Naming:** four-digit sequence + kebab-case slug. The sequence is allocation order,
not priority. Never renumber — links break.

---

## Right-sizing: three tracks

A full eight-stage pass on a typo is how a process gets abandoned in week two.
Pick a track at stage 1 and record it in `intent.md`. The track is a floor, not a
ceiling — anyone can ask for more rigour, nobody may quietly take less.

| Track | When | Required stages | Skippable |
|-------|------|-----------------|-----------|
| **S — Small** | Bug fix, copy change, dependency bump, refactor with no behaviour change | 1 (3 lines), 5, 6, 7 | 2, 3, 4 |
| **M — Medium** | New endpoint, new screen, change to an existing feature's behaviour | 1, 2, 4, 5, 6, 7 | 3 unless user-facing |
| **L — Large** | New product, new subsystem, anything touching auth/payments/PII, anything with a migration | All 8 | None |

Track S has no spec, so no Gherkin scenarios to approve: stage 6 validates against the
outcome stated in `intent.md` and says so in the report.

**Who decides:** whoever opens the intent proposes the track; the reviewer on the
eventual PR can reject the work for being under-tracked. Two forced escalations to L
regardless of size:

- It touches authentication, authorization, secrets, payments, or personal data.
- It changes a database schema or any public API contract.

---

## Stage 1 — Intent

**Purpose:** get the idea out of someone's head and into version control before it
has been distorted by solutioning.

**Input:** a person with an idea or a problem.

**The AI's job:** interview, don't transcribe. The originator will describe a
solution; your job is to find the problem underneath it. Ask, in roughly this order:

1. What is happening today that shouldn't be — or not happening that should?
2. Who feels this? How often, and what do they do instead right now?
3. If this were solved, what would be observably different? (Push for something
   measurable. "Users would be happier" is not an outcome.)
4. What systems, teams, or data does this touch?
5. What's deliberately out of scope?
6. What do we not know yet?

Then propose a track (S/M/L) with a one-line reason and get agreement.

**Artifact:** `specs/NNNN-slug/intent.md`

```markdown
# Intent: <title>

**Originator:** <name>   **Date:** <YYYY-MM-DD>   **Track:** S | M | L
**Track reason:** <one line>

## Problem
<One paragraph. What is wrong today, for whom, how often. No solution.>

## Proposed outcome
<One paragraph. What is observably different when this is done. Measurable if possible.>

## Affected systems
<Services, repos, data stores, third parties, teams.>

## Constraints
<Deadlines, budget, regulatory, technical, political. What we cannot change.>

## Out of scope
<What this explicitly does not include. Protects the spec from creep.>

## Open questions
<Numbered. Each needs an owner before stage 2 completes.>
```

**Gate:** problem and outcome each fit in one paragraph and contain no implementation
detail. Track agreed. Committed.

> **Anti-pattern:** an `intent.md` that names a technology. If it says "we need
> Redis," you have skipped to stage 2 and probably to the wrong answer.

---

## Stage 2 — Requirements

**Purpose:** turn intent into a specification complete enough that a competent
engineer who wasn't in the room could build it — and so could an AI.

**Input:** `intent.md`, plus the team, plus any organizational skills/policies
available in the repo.

**The AI's job:** work the checklist below section by section. Do not let a section
pass with silence — either it gets an answer or it gets an explicit `N/A because…`.
Surface disagreement rather than papering over it: where the team is split, record
both positions and flag it for the decision owner.

This is also the stage where organizational standards checks belong — the security,
data-handling, and compliance sections below are exactly the topics that have
standards. Check them here, before any code exists, not at review time.

### Acceptance criteria are Gherkin scenarios, and a person approves them

Section 12 is not a checklist. It is a set of **scenarios** in `Given / When / Then`,
because they are the contract stage 6 validates against, and a line like "invites work"
can't be validated by anyone.

- **One behaviour per scenario, one `When`.**
- **Declarative:** "When the admin removes Sam", not "When I click the red button".
  Stage 3 decides the UI; the scenario must survive it changing.
- **Concrete values:** "within 300 ms", "a 401", "after 7 days" — never "quickly".
- **Tag each with the FR it proves** (`@FR-3`). Every FR gets at least one; a scenario
  proving no FR is scope creep or a missing requirement.
- **Write the unhappy paths:** invalid input, not permitted, boundary, dependency down,
  concurrent action, empty state. Every threat in section 3 becomes a `@security`
  scenario.
- **`Scenario Outline` + `Examples`** for one behaviour over several values.
- **No implementation detail** unless the interface itself is the requirement.

Settle in section 7 how they will be run: a BDD runner, ordinary tests that cite the
scenario, or manual.

**Approval is a human act.** The AI drafts the scenarios with
`Acceptance status: draft` and **never sets `approved` itself**. A named person does —
at minimum the decision owner for scope, and for a Tier 1 or 2 change also the owner
named for security or engineering. The record says who, when, and where (PR review,
chat, meeting). If the approver isn't present, the stage is **blocked on approval**,
which is a correct outcome.

Once approved the scenarios are frozen. Any add, edit or removal sets the status back to
`draft`, goes in the amendment log, and needs re-approval. Commit the approved state, so
stage 6 can tell what was approved.

**Artifact:** `specs/NNNN-slug/spec.md`. If it grows past roughly 500 lines, split
it — `spec.md` plus `spec-security.md`, `spec-data.md` — and keep `spec.md` as the
index.

````markdown
# Spec: <title>

**Status:** draft | in review | accepted
**Intent:** ./intent.md
**Decision owners:** <who signs off on what>

## 1. Functional requirements
Numbered, testable, each independently verifiable.
- FR-1 ...
- FR-2 ...

## 2. Non-functional requirements
- Performance: <latency/throughput targets, and at what load>
- Scale: <expected volume now and in 12 months>
- Availability: <target, and what degraded looks like>
- Accessibility: <standard, e.g. WCAG 2.2 AA>
- Browser/device/platform support:
- Localization / timezone / currency:

## 3. Security
- Authentication: <how users prove identity>
- Authorization: <who may do what; resource-level checks>
- Data classification: <public / internal / confidential / restricted>
- PII or PHI involved: <yes/no — if yes, which fields and what handling>
- Secrets needed: <what, and which secrets manager holds them>
- Threats considered: <the ones that matter here, not a generic OWASP recital>
- Input validation and output encoding boundaries:
- Audit logging: <what gets logged, what must never be logged>
- Applicable standards: <org standards consulted, with reference>

## 4. Governance and compliance
- Regulatory scope: <GDPR / PCI / HIPAA / SOC 2 / none>
- Data residency:
- Retention and deletion:
- Approvals required before release:
- Review tier: <1 critical / 2 high / 3 standard / 4 low>

## 5. Tech stack decisions
For each choice: what, why, what was rejected, and what it costs us.

| Decision | Choice | Rejected alternatives | Rationale |
|---|---|---|---|

New dependencies — pin versions, check CVEs, check licence:

| Package | Version | Licence | CVE check | Why this one |
|---|---|---|---|---|

## 6. Data and interfaces
- Schema changes: <tables, columns, indexes, and the migration plan>
- Migration reversibility: <how we roll back>
- API contracts: <endpoints, shapes, versioning, breaking-change policy>
- Events published/consumed:
- Third-party integrations:

## 7. Automated testing requirements
- Unit: <what must be covered; any threshold>
- Integration: <which boundaries — data access, APIs — get real tests>
- End-to-end: <which user journeys>
- How the section 12 scenarios are run: <BDD runner, ordinary tests citing the
  scenario, or manual>
- Security tests: <invalid token, expired session, unauthorized access,
  injection payloads, boundary conditions — required for anything Tier 1>
- Performance tests: <if any, and against what target>
- Fixtures and test data: <synthetic only; where it lives>
- **The one command:** <e.g. `make test` — the single command that verifies everything>
- **Healthy output:** <what passing looks like, exactly>

## 8. Local development environment
- Containers needed: <yes/no; which services>
- How a developer runs this locally, from clone to working:
- Seed/fixture data:
- What cannot be run locally, and how it's covered instead:

## 9. Deployment and CI/CD
- Pipeline stages: <build, test, SAST, SCA, deploy>
- Environments and promotion path:
- Feature flag or dark launch:
- Migration ordering vs. code deploy:
- Rollback procedure: <specific steps, not "revert">
- Monitoring and alerting to add: <what signals tell us this is broken>
- Runbook updates needed:

## 10. Observability
- Metrics:
- Logs (and what must never appear in them):
- Traces:
- Dashboards / alerts:

## 11. Risks and open questions

| # | Risk or question | Owner | Resolution | Status |
|---|---|---|---|---|

## 12. Acceptance criteria
Acceptance status: draft | approved
Approved by: <name, role — never the AI>   Approved on: <date>   Approved via: <where>

```gherkin
Feature: <name>
  Background:
    Given <state shared by every scenario>

  @FR-1
  Scenario: <the behaviour, in business language>
    Given <context>
    When <the one action>
    Then <the observable outcome>

  @FR-2 @error
  Scenario: <what goes wrong, and how it is handled>
    ...
```

### Amendments after approval
Date | change to scenarios | why | re-approved by
````

**Gate:** every section answered or `N/A because…`. All stage-1 open questions
resolved or promoted to section 11 with an owner. Every FR has a scenario, every
scenario cites an FR, every section 3 threat has a `@security` scenario. **Section 12 is
`Acceptance status: approved` by a named person who is not the AI.** Decision owners
signed off on the rest. Committed.

---

## Stage 3 — Design

**Purpose:** decide what the user actually sees and touches, before code hardens the
wrong choice. Skippable on track S, and on track M when nothing is user-facing.

**Input:** `spec.md`, with section 12 `Acceptance status: approved`. If it is still
`draft`, stop and send the user back to stage 2.

**The AI's job:** push past "make it look nice." Usable and beautiful are separate
questions and both need answering. Work through every state, not just the happy one —
empty, loading, partial, error, offline, too much data, first-run. Those states are
where products feel broken.

### First, agree what gets produced

This is the one stage whose output a human has to *look at*. A written description of a
layout is not a layout. So before describing anything, **ask** what visual artifacts
this feature needs:

| Artifact | What it settles | Pick it when |
|---|---|---|
| **Wireframe** | Structure, hierarchy, placement. No colour or brand | The open question is *what goes on the screen* |
| **Mockup** | The visual: brand, colour, type, spacing. Static | The open question is *how it should look* |
| **Prototype** | Flow and interaction. Clickable, stateful | The open question is *how it should feel to use* |
| **None** | Nothing new — the existing design system answers it | The pattern exists and is reused as-is |

More than one is normal: wireframe to settle structure, mockup once it is settled.
Recommend from what is actually uncertain rather than presenting a menu. A deliberate
"none" is a valid answer and often the right one — don't manufacture artifacts for a
screen that reuses an existing pattern.

Then find out which **brand decisions are open** versus already settled by an existing
system: colour palette and semantic roles, light and dark, typography and licensing,
grid and spacing, iconography, motion, logo, and favicon.

### If designs already exist, still ask

A linked Figma file, an attached mockup, a brand guide, an existing screen to match —
none of these mean this stage is done. Ask which applies:

- **Use as-is** — reference it, produce nothing new.
- **Create new, using it as reference** — new artifacts for this feature, consistent
  with the existing work. **This is the default, and the case most often missed.**
- **Extend it** — add to the existing file or system in place.

An existing design is a reference, not a substitute for designing this feature. Ask
even when the user has just handed over a link — especially then. Where new work and a
referenced design disagree, record which is authoritative and why; silent divergence
means the build matches neither.

**Artifact:** `specs/NNNN-slug/design.md`, plus the visual artifacts themselves under
`specs/NNNN-slug/design/` — see [Storing design artifacts](#storing-design-artifacts).

```markdown
# Design: <title>

**Spec:** ./spec.md

## Artifacts produced
Per artifact: fidelity (wireframe/mockup/prototype), what uncertainty it settles,
status. Or "none — reuses <named pattern>".

## Existing designs referenced
Per source: link, how it's used (as-is / reference / extended), and whether it or
this document is authoritative.

## Artifact inventory
Every file under design/: what it is, its editable source, status, authoritative?

## Users and context
Who uses this, on what device, in what situation, how often, how skilled.

## Primary flows
For each: entry point → steps → exit. Name the shortest path to value.

## Screens and components
Per screen: purpose, content hierarchy, primary action, secondary actions,
what's reused from the existing system, what's new.

## States
Per screen or component:
- Empty (first run, and after deleting everything)
- Loading (and slow-loading — what after 3 seconds?)
- Partial / paginated
- Error (per error class, with the actual copy)
- Success / confirmation
- Disabled / no-permission

## Copy
Exact strings for labels, buttons, empty states, errors. Errors say what happened
and what to do next. No "an error occurred."

## Visual design
Colour palette and semantic roles, light and dark, type families and licensing, type
scale, spacing, grid and breakpoints, elevation, iconography, motion. Mark each
"settled by <system>" or "decided here" with values. Only justify net-new tokens.

## Logo and favicon
Source mark, exported sizes, dark-background variant. Store the source, not only the
exports — a 16px PNG cannot be regenerated.

## Accessibility
Keyboard path through every flow. Focus order and visible focus. Contrast ratios
measured against the actual palette. Screen-reader labels and live regions.
Reduced-motion behaviour. Target sizes.

## Responsive behaviour
What changes at each breakpoint. What is the mobile experience, specifically.

## Open design questions
```

### Storing design artifacts

Design artifacts are part of the spec. They belong with it, not in a chat scrollback or
someone's local folder:

```
specs/NNNN-slug/
  design.md                  describes and indexes
  design/
    wireframes/  mockups/  prototype/
    brand/                   palette, type scale, tokens
    icons/                   favicon source + exports
    exports/                 pulled from external tools
```

Three rules that stop this rotting:

- **Keep the editable source**, not just the exported image. An export you can't edit
  is a dead end.
- **Mark superseded files superseded** rather than deleting them, so a build
  referencing an old mockup finds out it's stale.
- **Large binaries:** store externally, link in the inventory, and record that the
  external copy is authoritative. Check whether the repo uses Git LFS first. Never let
  the only copy live somewhere that can vanish.

Every file under `design/` gets an inventory row in `design.md`. An unindexed file is
unreviewable — nobody can tell whether it's current.

**Gate:** artifact fidelity agreed, including a deliberate "none". Reuse-vs-reference
decided for any existing design, with authority recorded. Open brand decisions resolved
or marked settled. Every screen, flow and state described. Copy written. Contrast
measured against the real palette. Every `design/` file indexed. Committed.

---

## Stage 4 — Plan

**Purpose:** decide *how* the code gets written, and get that agreed, before any of
it is written. Two artifacts: a phased checklist for tracking, and detailed build
files the AI actually executes against.

**Input:** `spec.md` (section 12 `Acceptance status: approved` — if it is still `draft`,
stop and go back to stage 2), `design.md`, and the existing codebase.

**The AI's job:** read the codebase first — actually read it, don't assume. Then
propose phases. A good phase is independently verifiable: at the end of it something
runs and you can tell whether it worked. A phase that can only be verified after the
next three phases land is not a phase.

Interview the engineer on: what existing patterns to follow, what to reuse, where
the landmines are, what order minimizes risk, what they want to review closely.

### Artifact A: `BUILD_PLAN.md` — the phased checklist

The living progress tracker. Checkboxes get ticked during stage 5.

```markdown
# Build Plan: <title>

**Spec:** ./spec.md   **Design:** ./design.md
**Review tier:** <1|2|3|4>

## Phase 1 — <name>
**Goal:** <one line>
**Detail:** ./build/01-<slug>.md
**Done test:** <the command or check that proves this phase works>

- [ ] <task>
- [ ] <task>
- [ ] Tests written and passing
- [ ] Done test passes

## Phase 2 — <name>
...

## Cross-cutting
- [ ] `CLAUDE.md` updated if conventions or commands changed
- [ ] Dependency manifests updated and committed
- [ ] Migration tested forward and backward
- [ ] Security tests for Tier 1 paths written
- [ ] Docs / runbook updated

## Risks during build

| Risk | Mitigation | Trigger to stop and ask |
|---|---|---|
```

### Artifact B: `build/NN-<slug>.md` — how the code gets written

One per phase. This is the file an AI reads to implement. Specific enough that two
different engineers would produce substantially the same code.

```markdown
# Phase N: <name>

**Goal:** <what exists when this is done>

## Files

| File | Action | Purpose |
|---|---|---|
| src/... | create / modify | ... |

## Approach
Prose, not code dumps. The reasoning, the sequence, the shape of the solution.
Signatures and data structures where they matter. Reference the existing pattern
being followed by file and line.

## Patterns to follow
Point at real code in this repo: "mirror the error handling in
src/api/orders.ts:42-68."

## Do not
Specific things that would be wrong here, and why. This section prevents more
rework than any other.

## Tests
What tests, at what level, asserting what. Include the negative cases.

## Verification
The exact command, and what healthy output looks like.

## Open questions
Anything that must be answered before writing this phase.
```

**Gate:** engineer has read and approved the plan. Each phase has a done-test.
Committed **before** implementation starts.

> **Why the plan is committed first:** at merge time the plan and the diff should
> match. If they diverged, either the plan was wrong or the build wandered — both
> worth knowing, and you can only tell if the plan predates the code.

---

## Stage 5 — Build

**Purpose:** write the code, verifying as you go.

**Input:** `BUILD_PLAN.md` + the current phase's `build/NN-*.md`.

**The AI's job:**

1. Work one phase at a time. Do not start phase N+1 until phase N's done-test passes.
2. Tick checkboxes in `BUILD_PLAN.md` as you complete them — it is the live record.
3. Run the done-test yourself before claiming the phase is complete. Iterate on
   failures without being asked.
4. **Stop and ask** when: the plan is wrong, a requirement is ambiguous, you need a
   dependency the spec didn't list, the approach isn't working after two attempts, or
   you're about to touch something outside the plan's file list.
5. Never weaken a test to make it pass. Never mock away a security control. Never
   suppress a scanner finding. If a test blocks you, the test is probably right.
6. When the plan turns out to be wrong: update the plan file, note why, then proceed.
   The plan is a living document, but it changes deliberately and visibly.

**Artifact:** code, plus `BUILD_PLAN.md` with boxes ticked, plus any plan amendments.

**Gate:** all phase checkboxes ticked. Every done-test passing. No commented-out
tests, no skipped assertions, no TODO where a requirement should be.

> All generated code is a draft pending human review. Compiling is not correctness.

---

## Stage 6 — Test

**Purpose:** verify against the spec, not against the plan. The plan can be executed
perfectly and still miss the requirement.

**Input:** the code, `spec.md` section 12 (the Gherkin acceptance scenarios), section 7
(testing requirements).

**First, check the criteria are the approved ones.** Stage 6 validates against approved
acceptance criteria and nothing else.

1. Section 12 must say `Acceptance status: approved`, with who, when and where filled
   in. If it is `draft`, blank, or still a checklist, **stop**. Don't test, and don't
   write a report that reads as a result. Send the user back to stage 2.
2. The scenarios must be **unchanged since approval**. Find the approval commit
   (`git log -S"Acceptance status: approved" -- specs/NNNN-slug/spec.md`) and diff it
   against `HEAD`. Any hunk inside section 12 means they changed after approval: stop,
   re-approval is needed. If the approval was never committed, say so.
3. **Never edit a scenario to make it pass,** and never drop an inconvenient one. A
   scenario that is genuinely wrong is an amendment: report it, leave the result FAIL or
   blocked, and let a person re-approve a corrected one.

Track S has no section 12; validate against the outcome in `intent.md` and say so.

**The AI's job:** run the one command from spec section 7. Then validate **every
approved scenario, one at a time**, and produce evidence for each — not an assurance,
evidence. Scenarios validated must equal scenarios approved, so nothing was quietly
dropped. Where a scenario can't be verified automatically, say so and say what manual
check is needed. The `@security` scenarios are the security tests.

Then go looking for what the tests don't cover: boundaries, concurrency, the error
paths nobody exercises, what happens on second run.

**Artifact:** `specs/NNNN-slug/TEST_REPORT.md`

````markdown
# Test Report: <title>

**Date:** <YYYY-MM-DD>   **Commit:** <sha>

## Criteria validated against
Section 12 status: approved. Approved by <name, role> on <date> via <where>.
Approval commit <sha>; section 12 unchanged since. Scenarios approved / validated: n / n.

## Target
<The quantifiable target from spec section 7. e.g. "all tests pass, coverage >= 80%
on changed lines, p95 < 200ms.">

## Result
PASS | FAIL

## Automated suite
```
<actual output — the real thing, not a summary>
```

## Acceptance scenarios

| Scenario (verbatim from section 12) | FR | Verified by | Result |
|---|---|---|---|
| ... | FR-1 | `test/...` or manual step | pass / fail |

Totals: n scenarios — n pass, n fail, n manual.

## Security tests

| Case | Expected | Result |
|---|---|---|
| Unauthenticated request | 401 | |
| Wrong-user resource access | 403 | |
| Expired token | 401 | |
| Injection payload in <field> | rejected/escaped | |

## Scans
- SAST: <result>
- SCA / dependencies: <result, CVEs found, disposition>

## Not covered
Honest list of what isn't tested and what risk that leaves.

## Defects found

| # | Description | Severity | Fixed in | Status |
|---|---|---|---|---|
````

**Gate:** section 12 confirmed approved and unchanged since approval. Stated target met.
Every approved scenario has a result with evidence, and the count matches. Defects
either fixed or explicitly accepted by a named person.

> **Fixing a failing test:** write the failing test *first*, confirm it fails for the
> right reason, then fix the code. And don't let the agent edit the test file while
> fixing — that's where false green comes from.

---

## Stage 7 — Deploy

**Purpose:** get the change reviewed and shipped through the pipeline, with a human
making the merge decision.

### The hard rule

**The AI never merges a pull request. Ever.**

It may: create branches, commit, push, open PRs, write PR descriptions, respond to
review comments, push fixes.

It may not: merge, squash-merge, rebase-merge, enable auto-merge, close a PR as
merged, push to a protected branch, or bypass a required check.

The AI also asks before committing and before opening a PR. Those are outward-facing
actions and consent is per-change, not standing.

> **This rule is advisory until you enforce it.** A line in a markdown file is a
> suggestion an agent can drift from. What actually binds it:
> - **Branch protection** on `main` requiring PR + human code-owner approval. This
>   is the real control.
> - **A pre-tool hook** that blocks merge invocations and explains why. If you're using
>   the `sdlc` plugin, this ships wired up — nothing to install.
> - **`permissions.deny` entries** in `.claude/settings.json` for merge commands, as a
>   second layer. These can't travel in a plugin, so they're a per-repo addition;
>   `/sdlc:bootstrap` offers to merge them in.
>
> Do the branch protection at minimum. The doc alone binds nothing.

### The AI's job

1. Ask the user whether to commit. Show what will be committed.
2. Branch — never commit to `main` directly. Follow the repo's branch naming.
3. Commit with a message that says what changed and why, referencing the spec
   directory. Include the AI attribution marker your organization requires.
4. Ask whether to open a PR. If yes, write a description covering:
   - Link to the spec directory
   - What changed and why
   - Review tier and what that requires
   - `TEST_REPORT.md` summary and link
   - Anything a reviewer should look at closely
   - Breaking changes, migrations, rollback steps
   - What isn't covered by tests
5. Then stop. Report the PR URL. Offer to address review comments.
6. If CI fails, fix the code. Never skip the check, never suppress the finding.

**Artifact:** a PR, open, awaiting human decision.

### `REVIEW.md` — review policy

Put this at repo root so review is consistent and the AI knows what it's checking:

```markdown
# Review Policy

## Passes
1. **Correctness** — logic errors, off-by-one, null handling, race conditions,
   error paths, resource leaks.
2. **Spec compliance** — does the diff implement `spec.md`? Does it exceed it?
3. **Security** — injection, authz gaps, secrets, unsafe deserialization, weak
   crypto, sensitive data in logs.
4. **Tests** — do they test behaviour or implementation? Negative cases present?
   Any security control mocked away?
5. **Plan/diff match** — does the diff match `BUILD_PLAN.md`? Unexplained divergence
   is a finding.

## Severity

| Level | Meaning | Action |
|---|---|---|
| Critical | Exploitable, or data loss | Blocks merge |
| High | Wrong behaviour in a normal path | Blocks merge |
| Medium | Wrong behaviour in an edge case | Fix or file with owner |
| Low | Style, clarity, minor inefficiency | Author's discretion |

## Excluded
<Generated files, vendored code, fixtures — list them.>

## Repeated findings
A finding that appears three times becomes a rule in `CLAUDE.md`.
```

**Gate:** human approved. Human merged. Not the AI.

---

## Stage 8 — Maintain

**Purpose:** close the loop. Production tells you what the spec got wrong.

**Triggers:** an alert or threshold breach, a scheduled security scan finding, a
support pattern, a recurring review finding, a dependency CVE.

**The AI's job:** diagnose, then write the finding up as a new `intent.md` in stage-1
format and hand it to the service owner to triage — fix now, schedule, or dismiss.
Small and bounded? Propose it as a PR through the normal gates. Larger than that?
It's a new intent and it starts at stage 1.

When a fix ships, add that failure class to the test suite permanently. An incident
that can recur wasn't finished.

**Artifact:** a new `specs/NNNN-slug/intent.md`.

---

## Stage 9 — Retro

**Purpose:** improve the process itself. Stages 1–8 ship a feature; this one ships a
change to how features get shipped.

A skill or guidance edit changes behaviour in **every** repo running the process. By
this document's own tiering that is closer to Tier 1 than Tier 3, so a retro produces
evidence rather than an opinion, and a change advisory board — not the author, and not
the AI — decides when it releases.

**Trigger:** whatever the team chose at setup. On demand, after each feature ships, or
on a cadence. Record the choice per repo rather than assuming one.

### Evidence, not vibes

The process generates its own telemetry. Read it:

| Source | What it tells you |
|---|---|
| `BUILD_PLAN.md` amendment logs | Where plans were wrong → stage 4's guidance is wrong |
| `TEST_REPORT.md` "Not covered" sections | The same gap recurring → spec §7 is missing a line |
| Review findings appearing 3+ times | Promote to a rule |
| Stages skipped, artifacts missing | That gate is too expensive, or asks the wrong question |
| Track vs. actual effort | Track heuristics need work |
| Repeated stop-and-ask points | Ambiguity in a stage's instructions |

One occurrence is a quirk. Three is a process problem. Cite file and feature for each
finding — an uncited finding is an opinion, and the board should reject it.

### Two destinations

- **Repo-specific** findings go to that repo's `CLAUDE.md`, as an ordinary change.
- **Process-level** findings change the shared process and go through the board.

Conflating them is how a shared process accumulates one team's quirks. A retro that
finds nothing process-level is a good outcome, not a failed one.

### What the board receives

Three things together, because a proposal without evidence can't be assessed:

1. **A recommendation document** — evidence with citations, findings, the proposed
   change, repos affected, risk, and rollback.
2. **The actual diff**, on a branch. Not an intention to change something.
3. **Eval results** showing existing behaviour still holds. If the suite didn't cover
   what changed, a new case is part of the change, not a follow-up.

### Release, and the two-branch model

Process work lands on the development branch by pull request. **Board approval is the
merge into the release branch**, performed by a human. Repos track the release branch,
so they only ever run approved process.

**Rollback** is reverting that merge; repos pick it up on their next update.

Keep the diff as small as the finding justifies. A retro that rewrites six stages is
several changes pretending to be one, and nobody can assess it.

**Artifact:** a recommendation document, a pull request, and eval output — held with
the process, not in the product repo.

---

## The two supporting files

### `CLAUDE.md` — repo context

This is what stops the AI relearning your codebase every session. At minimum:

```markdown
# CLAUDE.md

## What this is
<One paragraph.>

## Commands
- Install: ...
- Dev: ...
- Test: `<the one command>`  -> healthy output: <what passing looks like>
- Lint / typecheck / build: ...

## Architecture
<Enough to navigate. Where things live and why.>

## Conventions
<Naming, error handling, logging, state, file layout. Point at exemplar files.>

## Common mistakes in this codebase
<Things that have gone wrong before. This section earns its keep fast.>

## Process
This repo follows `SPEC_SDLC.md`. Features live in `specs/NNNN-slug/`.
The AI never merges a PR.
```

Grow the "common mistakes" section from real review findings. When the same
correction happens three times, it belongs here.

### `.claude/settings.json` — the local guardrails

Markdown documents the process; hooks and permissions bind it.

The hooks are the enforcing layer, and they travel with the process. Permissions do
not — a plugin manifest can't carry them — so `permissions.deny` entries are a per-repo
addition: deny merge commands, deny reads of secret files, and pre-approve the safe
inner-loop operations so the process doesn't drown in prompts.

Neither is the real control. Branch protection on the remote is, because it holds when
the agent runs somewhere these files don't.

---

## Adopting this

**Stage 1 only, one feature.** Drop in `SPEC_SDLC.md`, write one `intent.md`, see how
it feels. The stages are ordered by dependency and Intent has no prerequisites.

Then, roughly in this order: `CLAUDE.md` (immediate payoff, low cost) -> stage 2 on
your next real feature -> stage 4 -> branch protection and the merge rule -> stages 6
and 7 -> `REVIEW.md` -> stage 8 when you have monitoring worth reacting to.

**Signs it's working:** less rework after build starts, higher first-pass merge rate,
shorter time from idea to committed spec, fewer "that's not what I meant" moments.

**Signs it's failing:** artifacts written after the code as paperwork, everything
tracked L, everything tracked S, specs nobody reads, gates waved through. All of
these are the same failure — the artifact stopped being the handoff and became a
formality. Fix it by making the next stage genuinely depend on the last one's output.

---

## Existing tools and tickets

Pick one source of truth per artifact and write it down:

- **Repo-first** — markdown is authoritative, Jira holds a link. Simplest. Preferred.
- **Legacy-first** — Jira is authoritative, markdown is a synced working copy.
- **Minimum** — whichever you choose, each side links to the other.

Don't maintain two authoritative copies. It always rots.
