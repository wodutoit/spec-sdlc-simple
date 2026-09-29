# SPEC_SDLC.md — Spec-Driven SDLC

> **Drop this file into any repo.** It is self-contained: an AI agent that reads it
> has everything needed to run the process. The `.claude/skills/` directory in the
> [spec-sdlc-simple](https://github.com/wodutoit/spec-sdlc-simple) repo is optional
> sugar that makes the stages trigger without being asked.
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
| 2 | **Requirements** | `spec.md` | Product + team + AI | Every checklist section answered or explicitly marked N/A |
| 3 | **Design** | `design.md` | Design + AI | Every user-facing screen/flow described; states and errors covered |
| 4 | **Plan** | `BUILD_PLAN.md` + `build/NN-*.md` | Engineer + AI | Phases independently verifiable; each has a stated done-test |
| 5 | **Build** | Code + checked-off plan | AI, engineer reviews | All phase checkboxes ticked; self-verification passing |
| 6 | **Test** | `TEST_REPORT.md` | AI, engineer reviews | Stated quantifiable target met; evidence attached |
| 7 | **Deploy** | PR (never a merge) | AI proposes, human decides | Human approval on PR; **AI never merges** |
| 8 | **Maintain** | New `intent.md` | Monitoring / AI / anyone | Loops back to stage 1 |

Stage 8 closes the loop — an incident, a regression, or a support pattern becomes a
new `intent.md` and re-enters at stage 1. It is where the process stops being a
pipeline and becomes a cycle.

---

## Where artifacts live

One directory per feature, numbered, under `specs/`:

```
specs/
  0001-user-invites/
    intent.md            # stage 1
    spec.md              # stage 2
    design.md            # stage 3
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
CLAUDE.md                # conventions, commands, architecture, how to verify
REVIEW.md                # what a review checks and at what severity
SPEC_SDLC.md             # this file
.claude/skills/          # optional: stage skills that auto-trigger
```

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
The checklist that says this feature is done. Each line maps to an FR.
- [ ] ...
````

**Gate:** every section answered or `N/A because…`. All stage-1 open questions
resolved or promoted to section 11 with an owner. Decision owners signed off.
Committed.

---

## Stage 3 — Design

**Purpose:** decide what the user actually sees and touches, before code hardens the
wrong choice. Skippable on track S, and on track M when nothing is user-facing.

**Input:** `spec.md`.

**The AI's job:** push past "make it look nice." Usable and beautiful are separate
questions and both need answering. Work through every state, not just the happy one —
empty, loading, partial, error, offline, too much data, first-run. Those states are
where products feel broken.

**Artifact:** `specs/NNNN-slug/design.md`

```markdown
# Design: <title>

**Spec:** ./spec.md

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
Type scale, colour tokens, spacing, elevation, motion. Reference the existing design
system by name. Only justify net-new tokens.

## Accessibility
Keyboard path through every flow. Focus order and visible focus. Contrast ratios.
Screen-reader labels and live regions. Reduced-motion behaviour. Target sizes.

## Responsive behaviour
What changes at each breakpoint. What is the mobile experience, specifically.

## Assets
Mockups, prototypes, Figma links. Note which is authoritative.

## Open design questions
```

**Gate:** every user-facing screen and flow described, every state covered, copy
written. Committed.

---

## Stage 4 — Plan

**Purpose:** decide *how* the code gets written, and get that agreed, before any of
it is written. Two artifacts: a phased checklist for tracking, and detailed build
files the AI actually executes against.

**Input:** `spec.md`, `design.md`, and the existing codebase.

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

**Input:** the code, `spec.md` section 12 (acceptance criteria), section 7 (testing
requirements).

**The AI's job:** run the one command from spec section 7. Then walk the acceptance
criteria one at a time and produce evidence for each — not an assurance, evidence.
Where a criterion can't be verified automatically, say so and say what manual check
is needed.

Then go looking for what the tests don't cover: boundaries, concurrency, the error
paths nobody exercises, what happens on second run.

**Artifact:** `specs/NNNN-slug/TEST_REPORT.md`

````markdown
# Test Report: <title>

**Date:** <YYYY-MM-DD>   **Commit:** <sha>

## Target
<The quantifiable target from spec section 7. e.g. "all tests pass, coverage >= 80%
on changed lines, p95 < 200ms.">

## Result
PASS | FAIL

## Automated suite
```
<actual output — the real thing, not a summary>
```

## Acceptance criteria

| # | Criterion | Verified by | Result |
|---|---|---|---|
| 1 | ... | `test/...` or manual step | pass / fail |

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

**Gate:** stated target met. Evidence attached. Defects either fixed or explicitly
accepted by a named person.

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
> - **`.claude/settings.json`** with a `permissions.deny` entry for merge commands
>   (`gh pr merge`, `git merge` onto protected branches).
> - **A pre-tool hook** that blocks merge invocations and explains why.
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

### `.claude/settings.json` — the actual guardrails

Permissions and hooks are what enforce the process. Markdown documents it; settings
binds it. At minimum: deny merge commands, deny writes to protected paths, and
pre-approve the safe inner-loop operations so the process doesn't drown in prompts.

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
