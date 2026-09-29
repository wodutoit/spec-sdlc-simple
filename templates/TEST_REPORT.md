# Test Report: <title>

**Date:** <YYYY-MM-DD>
**Commit:** <sha>
**Spec:** ./spec.md

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

## Acceptance criteria

Every line from spec section 12, with evidence. Not an assurance — evidence.

| # | Criterion | Verified by | Result |
|---|---|---|---|
| 1 | | `test/…` or <manual step> | pass / fail |

## Security tests

Required for anything Tier 1. Extend for the threats named in spec section 3.

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
