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

## 0.1.0 — unreleased

First release. Not yet approved for `release`.

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
