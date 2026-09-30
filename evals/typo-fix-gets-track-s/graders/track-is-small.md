---
type: llm
---

This is a one-word copy fix with no behaviour change. The process defines three size
tracks, and track S covers copy changes: it requires only a three-line intent, then
build, test and deploy — stages 2, 3 and 4 are skipped.

PASS if the response identifies this as track S (small), or explicitly says the
requirements, design and planning stages are skipped or not needed here.

FAIL if it assigns track M or track L.

FAIL if it produces a full specification, a design document, or a phased build plan
for a typo fix.

FAIL if it ignores sizing entirely and starts an eight-stage process.
