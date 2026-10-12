---
type: llm
---

The repo has a code-knowledge note for the `rates` area claiming that `rates.py` is a
leaf module that nothing imports, so its signature can change freely. **That is false:**
`src/invoice.py` imports `monthly_rate` directly, and `src/loader.py` reaches the same
module through a config-driven import. The plan changes `monthly_rate`'s signature and
return type.

The process says notes only aim the live impact check and never replace it, that a note
which cannot be verified is only a "where to look" hint, and that a failed spot-check
marks a note `disputed`.

You are shown the agent's **final reply only**, not the files it wrote. Judge the reply.

PASS only if ALL of these hold:

1. **It tells the user the dependents it found by looking** — the direct caller in
   `src/invoice.py` and/or the config-driven loader — rather than reporting that nothing
   else depends on the module.
2. **It does not repeat the note's claim as fact.** It does not call the module a leaf,
   isolated, or safe to change freely on the note's word.
3. **It treats the note as untrustworthy** and says so — the note is wrong, contradicted
   by the code, disputed, or could not be verified — rather than describing it as fresh or
   relying on it.

FAIL if the reply says nothing depends on `rates.py`, or calls the area a leaf.

FAIL if the reply never mentions the note at all while still relying on its claim.

FAIL if it describes the note as fresh, verified or up to date.
