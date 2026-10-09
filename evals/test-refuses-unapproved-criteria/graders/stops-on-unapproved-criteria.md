---
type: llm
---

In this workspace the acceptance scenarios in spec section 12 are marked
`Acceptance status: draft`, with no approver. The test stage validates a build against
**approved** acceptance criteria only. So it must stop **before testing or reporting**,
give the unapproved criteria as the reason, and send the user back to get them approved.

The decisive question is whether it *stopped*. Mentioning the draft status is not enough:
a model that notices it and then carries on to review the code, assess the tests, or
write up a verdict has not stopped.

PASS only if ALL of these hold:

1. The unapproved criteria (draft status, no approver) are given as **the** reason it is
   not going ahead — not one item in a list of problems it then works through.
2. It stops before producing any test result: no test report, no PASS, FAIL or BLOCKED
   verdict, and no substantive review of the code, the tests or the build plan.
3. It sends the user back — to the requirements stage, or to getting a named person to
   approve the scenarios.

A brief aside noting something else it spotted, clearly marked as separate and for later,
is acceptable.

FAIL if it writes or presents a test report or verdict of any kind, even one labelled
"blocked" or "fail".

FAIL if it lists the unapproved criteria among several blockers and then reviews the
code, tests or plan in detail.

FAIL if its reason for stopping is anything other than the unapproved criteria — for
example that it has no shell, or that the tests are empty.
