# Changelog

Every entry is a change advisory board release — a merge from `main` into `release`.
Product repos pick these up with `/sdlc:bootstrap --relock`.

Read this before relocking: it says what changed in the process you're about to run.

## Format

```
## <version> — <YYYY-MM-DD>

**Board decision:** <link to the retro report or PR>

### Changed
- <stage or skill> — what changed and why it matters to a consuming repo

### Migration
- <what a consuming repo must do beyond relocking, or "none">
```

---

## 0.3.0 — unreleased

**Board decision:** pending

### Changed

- **Acceptance criteria are now Gherkin scenarios.** Stage 2 section 12 was a checklist
  ("- [ ] invites work"), which nobody could validate. It is now `Given / When / Then`
  scenarios: one behaviour and one `When` each, declarative rather than click-by-click,
  concrete values, each tagged with the FR it proves (`@FR-3`). Every FR needs at least
  one scenario, every scenario must cite an FR, and every threat in section 3 becomes a
  `@security` scenario. Section 7 now records how the scenarios are run (BDD runner,
  ordinary tests citing the scenario, or manual).
- **A named person must approve the criteria, and the AI never does.** Section 12 carries
  an `Acceptance status` block recording who approved, when, and where. The AI drafts as
  `draft`. If the approver is not present the stage is *blocked on approval*, which is a
  correct outcome rather than a failure. Once approved the scenarios are frozen: any
  add, edit or removal returns the status to `draft`, goes in an amendment log, and needs
  re-approval.
- **Stage 6 validates against the approved criteria, and checks they are the approved
  ones.** It stops, writing no report, if the status is not `approved` or the criteria
  are still a checklist. It compares section 12 against the approval commit and stops if
  any scenario changed since. It validates every approved scenario with evidence, checks
  the count of validated equals approved, and never edits or drops a scenario to make it
  pass; a wrong scenario is an amendment that needs re-approval.
- **Stages 3 and 4 refuse to start on unapproved criteria**, and send the user back to
  stage 2.
- **Track S is exempt.** It skips stage 2, so there is no section 12 to approve; stage 6
  validates against the outcome in `intent.md` and says so in the report.
- `templates/TEST_REPORT.md` gains a "Criteria validated against" block (approver, date,
  approval commit, unchanged-since check, approved/validated counts) and the acceptance
  table is now per scenario with an FR column.

### Fixed

- The 0.2.1 entry's board-decision link still read `PR #__`. It is now PR #3.

### Migration

**This one has a cost.** A spec written before this release has a checklist in section
12 and no approval status, and stage 6 will stop on it: a checklist is not Gherkin, and
nobody approved it. Stages 3 and 4 will stop on it too.

For a feature already in flight: convert section 12 to Gherkin scenarios tagged to the
FRs, get a named person to approve them, and commit that state. There is deliberately no
bypass, because a gate that can be skipped quietly is not a gate. Specs for features
already shipped need no change.

---

## 0.2.1 — 2026-10-09

**Board decision:** released via [PR #3](https://github.com/wodutoit/spec-sdlc-simple/pull/3), merged into `release` as `2f3c00e`.

Documentation only. No skill, hook, template or eval behaviour changes, so there is
nothing for a consuming repo to do beyond relocking.

### Fixed

- `release` still described 0.2.0 as "unreleased" with the board decision "pending", and
  0.1.0 as "not yet approved", although both had shipped. Both entries now carry their
  release dates and the commits or PR that shipped them.

### Changed

- `CONTRIBUTING.md` release steps reordered so the version bump and changelog update
  happen **in the release PR, before the merge**. Done afterwards, the edit lands on
  `main` only and `release` — the branch product repos clone — keeps saying
  "unreleased". That is what caused the fix above.

### Migration

None.

---

## 0.2.0 — 2026-10-09

**Board decision:** approved — [PR #2](https://github.com/wodutoit/spec-sdlc-simple/pull/2), merged into `release` as `38a1f0f`. The change itself had landed on `main` in `3ef9fc5` without its own PR.

### Changed

- **Stage 3 now agrees what gets produced before describing anything.** It asks whether
  the feature needs a wireframe, mockup, prototype, or a deliberate "none", and
  recommends based on what is actually uncertain. Previously it went straight to
  describing screens, so a feature could pass the stage with nothing a human could look
  at.
- **A linked design no longer short-circuits the stage.** Where mockups, a Figma file or
  a brand guide already exist, Stage 3 asks whether to use them as-is, create new
  artifacts using them as reference (the usual answer), or extend them in place. The
  authoritative side is recorded so new work and a referenced design can't silently
  diverge.
- **Brand decisions are explicit.** Colour and semantic roles, light and dark,
  typography and licensing, grid and spacing, iconography, motion, logo and favicon are
  each marked "settled by <system>" or decided here with values. Favicon and app icons
  were previously not mentioned anywhere.
- **Design artifacts are now stored and indexed.** They live under
  `specs/NNNN-slug/design/`, every file gets an inventory row in `design.md` recording
  its editable source, status and whether it is authoritative. Guidance covers keeping
  sources over exports, marking superseded files, and handling large binaries.
- Contrast ratios must now be measured against the actual palette, which ties the
  accessibility check to the colour decision rather than leaving it abstract.

### Added

- Eval case `design-asks-before-producing-artifacts` — fidelity agreed and the linked
  design's role settled **before** the document is written. Measured **with 1.00,
  without 0.00, Δ +1.00**.
- Eval case `design-stores-artifacts-with-spec` — artifacts stored under
  `specs/NNNN-slug/design/` and indexed. Measured **Δ +1.00**.
- Both cases seed a workspace via `case.yaml` + `fixture.sh`, the first in the suite to
  do so.
- **The full eight-case suite has now been run** (previously only the two design cases).
  Positive Δ on four cases (`typo-fix` +1.00, both `design` +1.00, `vague` +0.50); Δ 0.00
  on the four prohibition cases, which are regression guards rather than proof of value.
- `build-refuses-to-weaken-test` rebuilt with a real failing-test fixture and two
  deterministic graders. It first scored Δ −1.00, which was an artifact of an empty
  workspace and not a regression.
- Verified the suite can fail: removing the merge prohibition from `skills/deploy` turned
  the `declines-and-explains` grader PASS 3–0 → FAIL 3–0.
- `evals/README.md` documents the flags, how to read Δ, case-authoring pitfalls, and a
  trap worth knowing: a run that fails at startup still exits 0 and prints plausible
  scores.

### Migration

None. Existing `design.md` files stay valid; the new sections apply to the next feature
that reaches Stage 3. A repo mid-way through Stage 3 can adopt them or finish as-is.

---

## 0.1.0 — 2026-09-30

**Board decision:** initial release — the first commit on `release`, `3a701bf`.

First release.

### Added

- Stages 1–8: intent, requirements, design, plan, build, test, deploy, maintain —
  each with its own skill, artifact and gate.
- **Stage 9 — Retro**: improves the process itself, gated by a change advisory board.
- Three size tracks (S/M/L) so small work stays cheap, with forced escalation to L for
  anything touching auth, secrets, payments, personal data, schemas or public APIs.
- `SPEC_SDLC.md` — the whole process in one self-contained file, usable by any agent.
- Ten artifact templates, including the retro recommendation.
- `scripts/block-merge.sh` — blocks merges, force pushes, protected-branch pushes and
  `--no-verify`. Reads extra protected branches from `.claude/spec-sdlc.json` as a
  union with its defaults, so config can add protection but never remove it.
- `scripts/check-staleness.sh` — reports when a repo's process is behind, when its
  lock file is stale, or when the clone is on an unapproved branch.
- `/sdlc:bootstrap` — sets a repo up, and `--relock` / `--reconfigure` keep it current.
- An eval suite of six cases as the regression guard for process changes.

### Known gaps

- `claude plugin eval` does not exist on Claude Code v2.1.177, so the eval suite has
  never been executed and its graders are unverified. Retro reports must say so rather
  than implying evals passed. See `CONTRIBUTING.md`.

### Migration

None — nothing consumes this yet.
