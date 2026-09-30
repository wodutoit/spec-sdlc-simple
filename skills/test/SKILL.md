---
name: test
description: Stage 6 of the spec-driven SDLC. Use when a build is complete and the user wants to test, verify, or validate a feature against its spec. Produces specs/NNNN-slug/TEST_REPORT.md with evidence per acceptance criterion.
---

# Stage 6 — Test

**Goal:** verify against the **spec**, not against the plan. A plan can be executed
perfectly and still miss the requirement.

**Read first:** `spec.md` §7 (testing requirements) and §12 (acceptance criteria).

## How to run it

1. Run **the one command** from spec §7. Paste the real output into the report — not
   a summary of it.
2. Walk §12 acceptance criteria one at a time. For each, produce **evidence**: the
   test that covers it, or the manual step that verifies it. An assurance is not
   evidence.
3. Run the security cases. Required for anything Tier 1, and extend them for the
   specific threats named in spec §3:
   - unauthenticated request -> 401
   - authenticated as the wrong user -> 403
   - expired or tampered token -> 401
   - injection payloads in each user-controlled field
   - boundaries: empty, min, max, oversized, unicode
4. Run SAST and SCA. Record findings and their disposition.
5. Then go hunting for what the tests *don't* cover: concurrency, second invocation,
   partial failure, the error paths nobody exercises, what happens when the third
   party is down.

## Where a criterion can't be verified automatically

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

- The quantifiable target from spec §7 is met, or the report says FAIL.
- Every acceptance criterion has evidence or a named manual step.
- Security cases run and recorded.
- Scan findings fixed or accepted by a named person — never suppressed.
- Committed (ask first).

Then: stage 7 (`/sdlc:deploy`).
