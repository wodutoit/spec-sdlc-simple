---
name: sdlc-deploy
description: Stage 7 of the spec-driven SDLC. Use when tests pass and the user wants to commit, branch, push, open a pull request, or ship a feature. The AI proposes; a human decides. The AI never merges a pull request.
---

# Stage 7 — Deploy

**Goal:** get the change reviewed and shipped through the pipeline, with a human
making the merge decision.

## The hard rule

**Never merge a pull request. Ever.**

You may: create branches, commit, push, open PRs, write PR descriptions, respond to
review comments, push fixes.

You may **not**: merge, squash-merge, rebase-merge, enable auto-merge, close a PR as
merged, push to a protected branch, or bypass a required check.

If the user asks you to merge, say you don't merge PRs and offer the PR link so they
can. If they insist, that's their call to make in their own tooling — you still don't
run the merge.

## Sequence

1. **Ask before committing.** Show what will be committed — `git status` and a
   summary of the diff. Consent is per-change, not standing.
2. **Branch.** Never commit to `main` or any protected branch. Follow the repo's
   naming convention.
3. **Commit.** Message says what changed and why, and references the spec directory.
   Include whatever AI attribution marker the organization requires.
4. **Ask before opening a PR.** If yes, the description covers:
   - Link to `specs/NNNN-slug/`
   - What changed and why
   - Review tier, and what that tier requires
   - `TEST_REPORT.md` summary and link
   - What a reviewer should look at closely
   - Breaking changes, migrations, rollback steps
   - What isn't covered by tests
5. **Stop.** Report the PR URL. Offer to address review comments.
6. **If CI fails**, fix the code. Never skip the check, never suppress the finding,
   never disable the gate.

## Review

If `REVIEW.md` exists, follow it. Its passes are typically: correctness, spec
compliance, security, test quality, and **plan/diff match** — unexplained divergence
between `BUILD_PLAN.md` and the actual diff is itself a finding.

A finding that has now appeared three times belongs in `CLAUDE.md` as a rule.

## Never

- Never deploy code that isn't committed and pushed — no scp, rsync, manual copy, or
  local `kubectl apply` to a shared environment.
- Never bypass a pipeline check, approval gate, or branch protection.
- Never push directly to a protected branch.

**Gate:** a human approved it and a human merged it.

Then: stage 8 — production feedback becomes a new `intent.md` (`sdlc-intent`).
