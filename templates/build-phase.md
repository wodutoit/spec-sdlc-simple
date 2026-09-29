# Phase N: <name>

> Copy to `build/NN-<slug>.md`. One per phase in `BUILD_PLAN.md`.
>
> Specific enough that two different engineers reading it would produce
> substantially the same code.

**Goal:** <what exists when this is done>
**Plan:** ../BUILD_PLAN.md

## Files

| File | Action | Purpose |
|---|---|---|
| `src/…` | create | |
| `src/…` | modify | |
| `test/…` | create | |

## Approach

<Prose, not a code dump. The reasoning, the sequence, the shape of the solution.
Function signatures and data structures where they matter. If you find yourself
pasting the whole implementation, the plan has become the code — pull back.>

## Patterns to follow

<Point at real code in this repo, by file and line.>

- Error handling: mirror `src/api/orders.ts:42-68`
- Validation: mirror `src/lib/validate.ts`

## Do not

<Specific things that would be wrong here, and why. This section prevents more rework
than any other in the document.>

- Do not <thing> — because <reason>

## Tests

| Test | Level | Asserts |
|---|---|---|
| | unit / integration / e2e | |

Include the negative cases: bad input, missing auth, wrong user, boundary values,
second invocation.

## Verification

**Command:** `<exact command>`
**Healthy output:** <what passing looks like>

## Open questions

<Anything that must be answered before this phase can be written. If there are any,
this phase is not ready to build.>
