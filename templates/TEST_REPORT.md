# Test Report: <title>

**Date:** <YYYY-MM-DD>
**Commit:** <sha>
**Spec:** ./spec.md

## Criteria validated against

Stage 6 validates against **approved** acceptance criteria only. Confirm this before
anything below means anything.

| Check | Value |
|---|---|
| §12 `Acceptance status` | approved |
| Approved by | <name, role> |
| Approved on / via | <YYYY-MM-DD> / <PR review, chat, meeting> |
| Approval commit | `<sha>` |
| §12 unchanged since that commit | yes — `git diff <sha> HEAD` shows no hunk inside §12 |
| Scenarios approved / validated | <n> / <n> |

<If §12 was not approved, or changed after approval, do not complete this report. Stop
and send the user back to the requirements stage. For a track S change there is no §12:
say so here and name the `intent.md` outcome validated instead.>

## Target

<The quantifiable target from spec section 7. e.g. "all tests pass, coverage >= 80%
on changed lines, p95 < 200ms at 100 rps.">

## Result

**PASS | FAIL**

## Automated suite

Command: `<the one command>`

```
<actual output — the real thing, pasted, not a summary of it>
```

## Acceptance scenarios

Every scenario from spec §12, with evidence. Not an assurance — evidence. Do not edit,
add or drop a scenario here: a scenario that is wrong is an amendment that needs
re-approval, not a row to quietly change.

| Scenario | FR | Verified by | Result |
|---|---|---|---|
| <scenario name, verbatim from §12> | FR-1 | `test/…` or <manual step> | pass / fail |

**Totals:** <n> scenarios — <n> pass, <n> fail, <n> manual.

## Security tests

Required for anything Tier 1. These are the `@security` scenarios from §12, plus any
further threat named in spec section 3.

| Case | Expected | Result |
|---|---|---|
| Unauthenticated request | 401 | |
| Authenticated, wrong user's resource | 403 | |
| Expired / tampered token | 401 | |
| Injection payload in `<field>` | rejected or escaped | |
| Boundary: <min/max/empty/oversized> | <expected> | |

## Scans

- **SAST:** <result, findings, disposition>
- **SCA / dependencies:** <result, CVEs found, disposition>

Findings get fixed or formally accepted. Never suppressed.

## Not covered

<Honest list of what isn't tested and what risk that leaves. This section is the most
useful one in the document for a reviewer.>

## Defects found

| # | Description | Severity | Fixed in | Status |
|---|---|---|---|---|
| 1 | | | | open / fixed / accepted by <name> |

## Manual verification needed

<What a human still has to check, and how.>
