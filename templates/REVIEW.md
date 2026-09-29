# Review Policy

> Copy to repo root. Defines what a review checks, at what severity, and what blocks
> a merge. Applies to AI-generated and human-written code identically.

## Passes

Every PR gets all five.

1. **Correctness** — logic errors, off-by-one, null and undefined handling, race
   conditions, unhandled error paths, resource leaks, timezone and encoding bugs.
2. **Spec compliance** — does the diff implement `spec.md`? Does it quietly exceed
   it? Scope added without a spec update is a finding.
3. **Security** — injection across every context, missing or wrong authorization
   (especially resource-level / IDOR), hardcoded secrets, unsafe deserialization,
   deprecated crypto, sensitive data in logs or URLs, missing security headers.
4. **Test quality** — do the tests assert behaviour or implementation detail? Are the
   negative cases present? Has any security control been mocked away to make a test
   pass? Would these tests catch a regression?
5. **Plan/diff match** — does the diff match `BUILD_PLAN.md`? Unexplained divergence
   is a finding in itself; the plan's amendment log should explain any that exists.

## Severity

| Level | Meaning | Action |
|---|---|---|
| **Critical** | Exploitable vulnerability, or data loss or corruption | Blocks merge |
| **High** | Wrong behaviour in a normal path; missing authorization | Blocks merge |
| **Medium** | Wrong behaviour in an edge case; missing test for a stated requirement | Fix, or file with a named owner |
| **Low** | Style, clarity, naming, minor inefficiency | Author's discretion |

## Review tiers

From `spec.md` §4. Determines who must sign off.

| Tier | Trigger | Required reviewers |
|---|---|---|
| 1 Critical | Auth, authorization, crypto, session, access control, payments, PII | Senior engineer + security sign-off |
| 2 High | Infrastructure, IAM-adjacent, DB schema, deployment config | Senior engineer |
| 3 Standard | Business logic, UI, utilities, tests | Standard review |
| 4 Low | Comments, docs, formatting, no-logic refactor | Author self-review |

## Excluded from review

<List them explicitly — generated files, vendored dependencies, lock files, fixtures,
snapshots. Anything not listed here is in scope.>

## Merge authority

A human merges. The AI opens PRs, responds to comments, and pushes fixes — it never
merges, never enables auto-merge, and never pushes to a protected branch.

Enforced by branch protection on `main` requiring pull request review from a code
owner. The policy document describes the rule; branch protection is what binds it.

## Repeated findings

A finding that appears three times stops being a review comment and becomes a rule in
`CLAUDE.md`. Reviewers should say so when they notice the third occurrence.
