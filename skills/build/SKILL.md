---
name: build
description: Stage 5 of the spec-driven SDLC. Use when BUILD_PLAN.md exists with unticked phases and the user wants to implement, build, or write the code for a feature. Executes one phase at a time against build/NN-*.md, self-verifying before advancing.
---

# Stage 5 — Build

**Goal:** write the code, verifying as you go.

**Read first:** `BUILD_PLAN.md`, then only the current phase's `build/NN-*.md`.

## The loop

1. Pick the lowest-numbered phase with unticked boxes.
2. Read its `build/NN-*.md` in full.
3. Implement it — following the named patterns, respecting the "Do not" list.
4. Write the tests the phase specifies, including the negative cases.
5. Run the phase's **done test** yourself. Iterate on failures without being asked.
6. Tick the boxes in `BUILD_PLAN.md`. It is the live record, not a retrospective one.
7. Only then move to phase N+1.

Do not start phase N+1 until phase N's done test passes.

## Stop and ask when

- The plan is wrong or contradicts the spec.
- A requirement is ambiguous and the options lead to different code.
- You need a dependency the spec didn't list.
- The approach hasn't worked after two genuine attempts.
- You're about to touch a file outside the phase's file list.

Stopping to ask is cheap. Building the wrong thing confidently is not.

## Never

- **Never weaken a test to make it pass.** If a test blocks you, the test is probably
  right and your code is probably wrong.
- **Never mock away a security control.** The control is part of the behaviour under
  test.
- **Never suppress a scanner finding** — no `NOSONAR`, `nosec`, `nolint:gosec`,
  `@SuppressWarnings("security")`, no scanner exclusion entries. Fix it or escalate it.
- Never hardcode a secret, even a placeholder one, even temporarily.
- Never leave a TODO where a requirement should be.

## When the plan turns out to be wrong

Update the plan file. Log the change and the reason in the **Plan amendments** table.
Then proceed. The plan is living, but it changes deliberately and visibly — so that at
merge time the divergence between plan and diff is explained rather than discovered.

## Gate

- All phase checkboxes ticked.
- Every done test passing.
- Cross-cutting checklist complete: `CLAUDE.md` updated if conventions changed,
  dependency manifests updated and pinned, migration tested both directions.
- No commented-out tests, skipped assertions, or debug output.

All of this is a draft pending human review. Compiling is not correctness.

Then: stage 6 (`/sdlc:test`).
