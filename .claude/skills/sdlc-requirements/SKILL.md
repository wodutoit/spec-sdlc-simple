---
name: sdlc-requirements
description: Stage 2 of the spec-driven SDLC. Use when intent.md exists and spec.md does not, or when the user wants to define requirements, security, governance, tech stack, testing, local containers, or CI/CD for a feature. Produces specs/NNNN-slug/spec.md.
---

# Stage 2 — Requirements

**Goal:** a specification complete enough that a competent engineer who wasn't in the
room could build it — and so could you, later, with no memory of this conversation.

**Read first:** `intent.md`, plus any skills or policy files this repo carries.

## How to run it

Work the twelve sections of `templates/spec.md` in order. Per section:

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

## Splitting

Past roughly 500 lines, split into `spec-security.md`, `spec-data.md`, etc., and keep
`spec.md` as the index.

## Gate

- Every section answered or explicitly `N/A because…`.
- All stage-1 open questions resolved, or promoted to §11 with an owner.
- §7 names the one command and its healthy output.
- §12 acceptance criteria written, each mapping to an FR.
- Decision owners have signed off.
- Committed (ask first).

Then: stage 3 (`sdlc-design`) if user-facing, else stage 4 (`sdlc-plan`).
