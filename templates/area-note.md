---
area: <kebab-case-area-name>
summary: <one line, used in the index>
verified_at: <commit id you investigated against — see templates/code-knowledge.md>
verified_on: <YYYY-MM-DD>
status: ok                  # ok | disputed
confidence: medium          # low | medium | high
watched_paths:
  - <path or folder whose change should trigger the delta check>
last_touched_by: <specs/NNNN-slug>
---

# <Area name>

> Agent-maintained. Verify before trusting. Records where to look and how to query — never
> the result of an impact check. Target: about 150 lines or fewer.

## Entry points

| Path | Layer | Role |
|---|---|---|

## Layer map

<which module sits in which layer; names only, no caller lists>

## Data / schema touched

<tables or entities and their role here; link to existing schema docs rather than
restating them>

## Impact query

<the exact command or search that finds this area's dependents with this repo's tooling,
with `{paths}` where changed paths go. The query, not what it returned.>

```
<command>
```

## Non-obvious couplings and invariants

<claim: evidence (file:line or symbol)>

## Blind spots — what the tooling cannot see

Dynamic or reflective references that the impact tool and name-search will miss. The live
impact check searches each of these every time.

| Location | Construct | What it resolves to (if known) |
|---|---|---|

## Gotchas

<locking, transaction scope, boundary exceptions, config flags, things that bit a
previous change>

## Look here first

| If the feature is about… | Start at |
|---|---|

## Related

<links only: curated docs, wiki page titles, adjacent areas>

## Change log

- <date> · <specs/NNNN-slug> · <commit> · <what was re-verified or corrected>
