---
name: sdlc-plan
description: Stage 4 of the spec-driven SDLC. Use when spec.md exists and BUILD_PLAN.md does not, or when the user asks to plan a build, break work into phases, or decide how code will be written. Produces BUILD_PLAN.md (phased checklist) plus build/NN-*.md (detailed per-phase build files).
---

# Stage 4 — Plan

**Goal:** agree *how* the code gets written, before any of it is written.

**Read first:** `spec.md`, `design.md`, and **the actual codebase**. Read it — don't
assume. Find the patterns you'll be asked to follow and note them by file and line.

## Two artifacts

**A. `BUILD_PLAN.md`** — the phased checklist. Progress tracker; boxes get ticked in
stage 5. Template: `templates/BUILD_PLAN.md`.

**B. `build/NN-<slug>.md`** — one per phase, the file you'll actually implement
against. Template: `templates/build-phase.md`.

## What makes a phase

A phase is independently verifiable: at the end of it, something runs and you can
tell whether it worked. Each phase gets a **done test** — an exact command, and what
healthy output looks like.

If a phase can only be verified after the next three land, it isn't a phase. Merge it
or re-cut the boundaries.

Order phases so that risk lands early. The thing most likely to invalidate the
approach should be phase 1.

## Interview the engineer

Don't write the plan alone. Ask:

- Which existing patterns should this follow? What should it reuse?
- Where are the landmines in this part of the codebase?
- What order minimizes risk?
- What do you want to review closely versus wave through?
- Anything in the spec you think is wrong?

Iterate on the plan until they approve it. Approval before code is the point of
this stage.

## Writing the per-phase build files

Specific enough that two different engineers would produce substantially the same
code. That means:

- **Files** — a table of what gets created and modified, and why
- **Approach** — prose reasoning and sequence. Signatures and data structures where
  they matter. If you're pasting the whole implementation, pull back: the plan has
  become the code.
- **Patterns to follow** — real references: "mirror `src/api/orders.ts:42-68`"
- **Do not** — specific wrong turns, and why. This section prevents more rework than
  any other.
- **Tests** — what, at what level, asserting what. Include negative cases.
- **Verification** — the exact command and its healthy output.

## Gate

- Engineer has read and approved the plan.
- Every phase has a done test that is an actual command.
- Every phase has a `build/NN-*.md` with no open questions left in it.
- Cross-cutting checklist filled in.
- **Committed before implementation starts** — so plan and diff can be compared at
  merge time. Ask first.

Then: stage 5 (`sdlc-build`).
