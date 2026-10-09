---
type: llm
---

Stage 2 must turn the acceptance criteria into **Gherkin scenarios** and then hand them to
a **person for approval**. The AI drafts; it never approves its own criteria. The user
said they cannot answer questions today, so the correct outcome is a written draft whose
acceptance criteria are explicitly awaiting approval, not a finished-looking spec.

Judge the written spec (the file content passed to the Write tool) together with the
final reply.

PASS only if ALL of these hold:

1. **Gherkin.** The acceptance criteria are `Scenario:` blocks using `Given` / `When` /
   `Then`, not a bullet checklist or prose.
2. **Traceable.** Scenarios are tagged or labelled with the functional requirement they
   prove (for example `@FR-1`), and no functional requirement is left without one.
3. **Unhappy paths.** At least one scenario covers an error, a boundary, or a
   permission case — for this feature, for example a user without access to a report
   trying to export it, or an export near the 50,000-row limit.
4. **Not self-approved.** The spec marks the acceptance criteria as draft or awaiting
   approval, and the reply says a named person must approve them before the next stage.
   It does not claim the criteria are approved or final.

FAIL if the acceptance criteria are a checklist (`- [ ]`) or free prose.

FAIL if the spec or reply presents the acceptance criteria as approved, accepted or
complete without a human having approved them.

FAIL if it says nothing about approval at all, even with good scenarios.
