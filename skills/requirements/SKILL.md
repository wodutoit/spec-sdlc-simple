---
name: requirements
description: Stage 2 of the spec-driven SDLC. Use when intent.md exists and spec.md does not, or when the user wants to define requirements, acceptance criteria, security, governance, tech stack, testing, local containers, or CI/CD for a feature. Produces specs/NNNN-slug/spec.md with Gherkin acceptance criteria that a person must approve.
---

# Stage 2 — Requirements

**Goal:** a specification complete enough that a competent engineer who wasn't in the
room could build it — and so could you, later, with no memory of this conversation.

**Read first:** `intent.md`, plus any skills or policy files this repo carries.

## How to run it

Work the twelve sections of `${CLAUDE_PLUGIN_ROOT}/templates/spec.md` in order. Per section:

1. Propose a draft answer from `intent.md` and the codebase. Don't ask the user
   things you can find out yourself.
2. Ask only about what you genuinely can't determine.
3. Write the answer, or write `N/A because…`. **Never leave a section blank** — a
   blank section is an unanswered question wearing a disguise.

Where the team disagrees, record both positions and flag it for the decision owner.
Do not paper over it with a compromise nobody chose.

## The sections that get skipped and shouldn't

These are the ones that cause rework when they're waved through:

- **§3 Security** — not a generic OWASP recital. Which threats apply *here*? What's
  the data classification? Which fields are PII? Where do secrets come from?
- **§4 Governance** — regulatory scope, retention, who approves release, review tier.
- **§5 Tech stack** — every choice needs the rejected alternatives and what it costs.
  Every new dependency: pinned version, licence, CVE check.
- **§7 Testing** — the part that matters most is **the one command** and **what its
  healthy output looks like**. Without those, stage 5 can't self-verify and stage 6
  has no target.
- **§8 Local dev** — can a developer run this from a clean clone? Containers needed?
- **§9 CI/CD** — specifically the rollback procedure. "Revert" is not a procedure.

This is where organizational standards checks belong — before code exists, not at
review time.

## §12 — acceptance criteria are Gherkin scenarios

Not a checklist. Scenarios in `Given / When / Then`, because they are the contract the
test stage validates against, and a checklist line like "invites work" can't be
validated by anyone.

Draft them **after** the FRs, §3 security and §6 interfaces are written, since those
are what they're derived from. Rules, in full in `${CLAUDE_PLUGIN_ROOT}/templates/spec.md`:

- **One behaviour per scenario, one `When`.**
- **Declarative:** "When the admin removes Sam", not "When I click the red button". The
  design stage decides the UI; the scenario must survive it changing.
- **Concrete values:** "within 300 ms", "a 401", "after 7 days" — never "quickly".
- **Tag each scenario with the FR it proves** (`@FR-3`). Every FR gets at least one; a
  scenario that proves no FR is scope creep or a missing requirement — find out which.
- **Write the unhappy paths:** invalid input, not permitted, boundary, dependency down,
  concurrent action, empty state. Every threat in §3 becomes a `@security` scenario.
- **Use `Scenario Outline` + `Examples`** for the same behaviour over several values.
- **No implementation detail** unless the interface itself is the requirement.

Also settle in §7 **how the scenarios will be run** — a BDD runner, ordinary tests that
cite the scenario, or manual. Ask; don't assume a tool the repo doesn't use.

### Get them approved — a person does this, never you

The scenarios decide what "done" means, so they get approved before the process moves
on. Stage 6 will refuse to validate against criteria that aren't.

1. Set `Acceptance status: draft`. **Never write `approved` yourself.**
2. Show the user the scenarios and ask who approves. At minimum the decision owner for
   scope; for a Tier 1 or 2 change (§4), also the owner named for security or
   engineering. Invite review from three angles: product reads for intent,
   engineering for feasibility, QA for what's missing.
3. Only on an **explicit** approval from a named person, set `approved` and record
   `Approved by` (name and role as they gave it), `Approved on`, and `Approved via`
   (PR review, chat, meeting — where the record lives). "Looks fine" in passing isn't
   approval; ask plainly.
4. If the approver isn't in this session, leave it `draft`, say the stage is **blocked
   on approval**, and name who and what they need to see. That is a correct outcome.

Once approved the scenarios are frozen. Any change — add, edit, remove — sets the status
back to `draft`, goes in the amendment log, and needs re-approval. Commit the approved
state so stage 6 can tell what was approved.

## Splitting

Past roughly 500 lines, split into `spec-security.md`, `spec-data.md`, etc., and keep
`spec.md` as the index.

## Gate

- Every section answered or explicitly `N/A because…`.
- All stage-1 open questions resolved, or promoted to §11 with an owner.
- §7 names the one command, its healthy output, and how scenarios are run.
- §12 is Gherkin: every FR has a scenario, every scenario cites an FR, every §3 threat
  has a `@security` scenario.
- **§12 `Acceptance status: approved`, by a named person who is not you.**
- Decision owners have signed off on the rest.
- Committed (ask first).

If §12 is still `draft`, the stage is not done. Say so and stop; don't hand over to
stage 3 or 4.

Then: stage 3 (`/sdlc:design`) if user-facing, else stage 4 (`/sdlc:plan`).
