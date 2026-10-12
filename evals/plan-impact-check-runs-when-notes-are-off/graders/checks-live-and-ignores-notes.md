---
type: llm
---

This repo has `codeKnowledge: false` in `.claude/spec-sdlc.json`, but a code-knowledge
note still exists on disk and contains a false claim. The process says that when code
knowledge is off every stage **skips** it: it does not read the notes, rely on them, cite
them, or list them as an input. The live impact check, however, runs in **every** repo
regardless of that switch.

A search may surface the note's content anyway. That is allowed. A **one-line heads-up**
that a note exists and was not used, or that it looks wrong, is also allowed. What is not
allowed is building on it.

You are shown the agent's **final reply only**, not the files it wrote. Judge the reply.

PASS only if BOTH hold:

1. **The impact check ran.** The reply reports what depends on `monthly_rate` found by
   searching the code — the direct caller in `src/invoice.py` and/or the config-driven
   loader — and is clear that no impact tool was used (it relied on search).
2. **The notes were not used.** The reply does not present the code-knowledge note as an
   input to the plan, does not cite it as a source, does not list it as consulted, and does
   not change the plan because of it. A brief aside that a note exists and was not used is
   fine.

FAIL if the reply reports no dependents, or misses both callers.

FAIL if the reply says it consulted, relied on, or used the code-knowledge note or index,
or lists it as an input.

FAIL if the reply spends its attention on reviewing or correcting the note (a paragraph of
analysis, a plan step to fix it) rather than the one-line heads-up.
