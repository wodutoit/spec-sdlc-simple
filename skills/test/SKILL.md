---
name: test
description: Stage 6 of the spec-driven SDLC. Use when a build is complete and the user wants to test, verify, or validate a feature against its spec. Validates the build against the approved Gherkin acceptance scenarios, refusing if they are unapproved or changed since approval. Produces specs/NNNN-slug/TEST_REPORT.md with evidence per scenario.
---

# Stage 6 — Test

**Goal:** verify against the **spec**, not against the plan. A plan can be executed
perfectly and still miss the requirement.

**Read first:** `spec.md` §7 (testing requirements) and §12 (the Gherkin acceptance
scenarios).

## Step 0 — check the criteria are the approved ones

You validate against **approved** acceptance criteria and nothing else. Before any
testing:

1. **§12 must say `Acceptance status: approved`**, with `Approved by`, `Approved on` and
   `Approved via` filled in. If it's `draft`, blank, or the criteria are still a
   checklist rather than Gherkin scenarios, **stop**. Do not test, and do not write a
   report that reads as a result. Tell the user the criteria were never approved and
   send them back to `/sdlc:requirements`.
2. **They must be unchanged since approval.** Find the approval commit and compare:

   ```bash
   git log -S"Acceptance status: approved" --format='%h %ad %an' --date=short -- specs/NNNN-slug/spec.md
   git diff <most-recent-sha> HEAD -- specs/NNNN-slug/spec.md
   ```

   Any hunk inside §12 means the scenarios changed after approval. Stop: the change
   needs re-approval through `/sdlc:requirements`. A hunk elsewhere in the spec doesn't
   matter here. If the approval was never committed, say so — you can't show what was
   approved.
3. **Never edit a scenario to make it pass,** and don't drop one that's inconvenient.
   Same rule as tests. A scenario that's genuinely wrong is an amendment: report it,
   leave the result as FAIL or blocked, and let a person re-approve a corrected one.

**Exception — track S.** A small change skips stage 2, so there is no §12. Validate
against the outcome stated in `intent.md` instead, and say in the report that this is
what you did.

## How to run it

1. Run **the one command** from spec §7. Paste the real output into the report — not
   a summary of it.
2. **Validate every approved scenario, one at a time.** For each, produce **evidence**:
   the test that covers it (cite the scenario by name or `@FR` tag), or the manual step
   that verifies it. An assurance is not evidence. Then check the count: scenarios
   validated must equal scenarios approved, so nothing was quietly dropped.
3. Run the security cases. These are the `@security` scenarios from §12 — run those,
   then extend for any other threat named in spec §3:
   - unauthenticated request -> 401
   - authenticated as the wrong user -> 403
   - expired or tampered token -> 401
   - injection payloads in each user-controlled field
   - boundaries: empty, min, max, oversized, unicode
4. Run SAST and SCA. Record findings and their disposition.
5. Then go hunting for what the tests *don't* cover: concurrency, second invocation,
   partial failure, the error paths nobody exercises, what happens when the third
   party is down. A gap you find that deserves a scenario is an amendment too — report
   it, don't add it silently.

## Where a scenario can't be verified automatically

Say so plainly, and say what manual check is needed. Put it under **Manual
verification needed**. Don't mark it pass on the strength of reading the code.

## Fixing a failure

1. Write the failing test **first**.
2. Confirm it fails for the right reason.
3. Then fix the code.
4. Do not edit the test file while fixing the code — that is where false green comes
   from.

## Report honestly

The **Not covered** section is the most useful part of the document for a reviewer.
Fill it in properly. If the result is FAIL, write FAIL.

## Write it

Path: `specs/NNNN-slug/TEST_REPORT.md`. Template: `${CLAUDE_PLUGIN_ROOT}/templates/TEST_REPORT.md`.

## Gate

- §12 confirmed `approved` and unchanged since approval — recorded in the report.
- The quantifiable target from spec §7 is met, or the report says FAIL.
- Every approved scenario has a result with evidence or a named manual step, and the
  count matches. Any failing scenario is fixed, or accepted by a named person.
- Security cases run and recorded.
- Scan findings fixed or accepted by a named person — never suppressed.
- Committed (ask first).

Then: stage 7 (`/sdlc:deploy`).
