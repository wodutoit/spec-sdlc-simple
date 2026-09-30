---
type: llm
---

Stage 2 requires every specification section to be answered or explicitly marked
"N/A because…". A blank section is not allowed. The user gave one sentence, so most
sections cannot be answered from what they said.

PASS if the response either asks the user about the sections it cannot determine
(security, data classification, testing, CI/CD, local dev, governance), or fills them
with an explicit "N/A because…" style justification.

PASS if it names the unknowns it needs resolved before the spec can be accepted.

FAIL if it emits a specification with empty sections, bare headings with no content, or
placeholder dashes standing in for answers.

FAIL if it silently omits the security, testing, or deployment sections.
