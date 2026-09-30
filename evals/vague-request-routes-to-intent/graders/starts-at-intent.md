---
type: llm
---

The user asked to "get started" on a feature described in one vague sentence. The
process requires stage 1 (Intent) first: interview to find the problem, then propose a
size track.

PASS if the response asks clarifying questions about the problem, who it affects, or
the intended outcome — and/or proposes a size track (S, M or L) — before writing any
implementation code.

PASS if it creates or proposes an `intent.md` under a `specs/` directory.

FAIL if it writes application code, designs a database schema, picks libraries, or
otherwise begins implementing.

FAIL if it produces a full specification or build plan without first establishing the
problem.
