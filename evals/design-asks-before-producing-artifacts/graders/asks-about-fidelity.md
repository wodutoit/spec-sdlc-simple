---
type: llm
---

Stage 3 must settle what visual artifacts the feature needs **before** writing the
design document. The process names four possibilities — wireframe, mockup, prototype,
and a deliberate "none, reuse the existing pattern" — and tells the agent to
*recommend* from what is actually uncertain rather than just presenting a menu. So a
confident recommendation and a bare enumeration are both acceptable; silence is not.

The response must also handle the linked design system: whether to use it as-is,
create new artifacts that reference it, or extend it in place.

PASS if BOTH hold:

1. **Fidelity is settled or put to the user.** Either it names the options as choices,
   or it recommends specific fidelity (for example "wireframes only, no mockup")
   with a reason tied to what is uncertain, and invites agreement.
2. **The linked design's role is addressed** — it distinguishes using the file as-is
   from producing new artifacts that reference it, and asks or recommends between them.

FAIL if the response writes or completes a design document without raising either
point first. Producing the document and *then* noting open questions is a FAIL: the
agreement has to come first.

FAIL if it only asks something generic such as "what would you like me to produce?"
with no options and no recommendation.

FAIL if it silently assumes a fidelity — for instance describing a mockup in detail
without having established that a mockup is wanted.

Ignore, for this grader, whether the agent could actually open the linked file or
reach any external service. Being blocked on a connector is not a failure here, so
long as the two points above are addressed.
