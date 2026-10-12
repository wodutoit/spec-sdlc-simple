# Code knowledge

Shared rules for every stage that reads or writes `.claude/code-knowledge/`. Read this
before consulting a note and before writing one.

## What it is for

Checking what a change touches is expensive, and it gets repeated from scratch on every
feature. Code knowledge makes that **live check cheaper by aiming it** — it records the
*inputs* to the analysis: where to start, the exact query to run, and what the tooling
cannot see.

It never records the *result*. The blast radius is recomputed live every time, so a note
can never go stale on it, and never reassure you wrongly. Cheaper because the work is
aimed, not because it is skipped.

## When it applies

Only when `.claude/spec-sdlc.json` has `config.codeKnowledge: true`. **Read that file
first, before you open, search or list anything under `.claude/code-knowledge/`** — the
check has to come before the exploration, not after it. If the file is absent, or the
value is false or missing, **skip code knowledge**: don't open, rely on, cite or act on any
note, even though the folder exists, and don't list notes under Knowledge used.

A broad `Glob` or `Grep` of the repo can surface the notes or their contents anyway.
That's fine — just don't build on it, and don't let it shape the plan. A **one-line
heads-up** is allowed: that a note exists and wasn't used, or that it looks wrong, since a
committed note that contradicts the code is worth knowing about. Keep it to that: no
review of the note, no fixing it, no change to the plan because of it.

Turning the switch off keeps the notes; it just stops using them.

The live impact check in stage 4 does **not** depend on this switch. It runs in every repo.

## Where notes live

```
.claude/code-knowledge/
  index.md            one row per area; the only file read on every plan
  areas/<area>.md     one small note per area
```

In the product repo, committed, next to the code they describe — derived from the code,
so they are only trustworthy if they can be checked against it. They are per-repo like
`CLAUDE.md`, `REVIEW.md` and `specs/`, and never sync from the process.

- **Business intent, cross-repo concepts and decision history** belong in the team
  knowledge base, not here.
- **Curated system docs:** keep these agent-maintained notes in their own folder. A note
  may link to a curated doc. Never mix them into it.
- **`CLAUDE.md`** holds stable, always-loaded conventions and commands. A note is
  per-area and verified on use. If a fact is true everywhere and rarely changes, it
  belongs in `CLAUDE.md`.

Templates: `${CLAUDE_PLUGIN_ROOT}/templates/area-note.md` and `knowledge-index.md`.

## What to keep

Facts that are hard to re-derive:

- entry points, and the layer each sits in
- non-obvious couplings and invariants
- **the impact query** for the area — the exact command or search that finds its
  dependents with your repo's tooling
- **blind spots**: dynamic or reflective references that the tooling and name-search
  cannot see (names built from strings, config-driven wiring, schema and SQL coupling,
  cross-repo callers)
- gotchas: locking, transaction scope, boundary exceptions, flags that change behaviour
- "look here first" pointers

## What not to keep

- full caller or dependency lists — they go stale at once; the impact tool regenerates them
- the result of any impact check, or a dated summary of one
- anything about the current feature's change
- code excerpts longer than a signature
- claims that rest only on the wiki
- **secrets, credentials, or customer or production data** — these are committed files

## Freshness: verify before you trust

Each note records `verified_at` (a commit id), `verified_on`, `status`, `confidence` and
`watched_paths`. On use:

1. **Delta check.** Has anything under `watched_paths` changed since `verified_at`?

   ```bash
   git diff --stat <verified_at> HEAD -- <watched_paths>
   ```

   If it can't be run — no shell, offline, or the revision is unknown (a squash-merge,
   rebase or shallow clone can orphan a commit id) — the note is **unverified**. Never
   treat "couldn't check" as "fresh".
2. **Classify.**

   | Class | Meaning | What to do |
   |---|---|---|
   | fresh | nothing changed under `watched_paths` | use as the starting map; trace only what this change adds |
   | partial | some watched files changed | re-investigate only those files |
   | stale | entry points moved or deleted, or `status: disputed` | investigate normally; use as a "where to look" hint at most |
   | missing | no matching note | investigate normally |
   | unverified | the delta check could not run | investigate normally; use only as a "where to look" hint |

3. **Spot-check.** Confirm at least one concrete claim in any note you rely on: open the
   cited file and confirm the symbol is there. A failed spot-check marks the note
   `status: disputed`, which is treated as stale, and logs a friction entry.
4. **Write-back.** Bump `verified_at` only for the parts you actually re-verified in this
   run — never for a note you merely read.

**What `verified_at` records.** The commit you investigated against: the base the work was
branched from, **not** the commit that carries your plan or note. On a feature branch
prefer `git merge-base HEAD <default-branch>`, which survives the branch being
squash-merged.

## Hard rules

- **Notes never make a risk call.** The live impact check, and any decision about track
  or review tier, are computed against the proposed change set. A note says where to look
  and can never say that nothing is there. A note, or a tool, reporting "no dependents"
  never lowers a track or tier — "nothing found by <tool or search>" is the most it can
  say.
- **Live findings may raise the track or review tier; nothing may lower it.**
- **A human reviews every write.** The skill proposes a diff, the person approves it, and
  nothing is committed without asking.
- **One note per area, about 150 lines or fewer.** Split the area if it grows. Prune
  entries that haven't been used in several features.
- **If a note conflicts with the wiki, the code wins.** Surface the discrepancy to the
  user; don't resolve it silently.
- A feature that changes an area makes its own note stale by design. The next delta check
  re-verifies only the changed files. That is expected.

## How each stage uses it

| Stage | Use | Where it records "Knowledge used" |
|---|---|---|
| 2 Requirements | read-only, to ground feasibility, interfaces and schema questions | one line in `spec.md` |
| 4 Plan | consult → live impact check → trace → **write-back after approval** | `BUILD_PLAN.md` |
| 5 Build | read the notes the plan used; propose `disputed` if a claim proves false | same section of `BUILD_PLAN.md` |
| 8 Maintain | read-only when diagnosing, through `/sdlc:intent` | the intent it writes |
| 9 Retro | reads the recorded entries as evidence | — |

Plan is the only stage that writes notes. Build may propose marking one `disputed`.

## "Knowledge used" — what to record

```
Knowledge used
- <area>: fresh | partial | stale | missing | unverified — used / re-verified in part / ignored, and why
Notes written or updated: <areas, or none>
Effort (self-reported):
  consult + trace:  <n> files read, <n> searches, <n> tool runs
  impact check:     <n> files read, <n> searches, <n> tool runs
Friction: <none | knowledge-misled entries>
```

The counts are the model reporting its own effort. That is indicative, not proof; the
retro treats it that way and needs several features in an area before concluding anything.

## Friction: `knowledge-misled`

Record one when a note failed its spot-check or sent the work down a wrong path:

| Field | Content |
|---|---|
| note | the area, and the claim that was wrong |
| feature | `specs/NNNN-slug` |
| what happened | one or two lines |
| correction | what change to the **note** or to the **template** would have prevented it |

The retro reads these. A wrong claim is a repo-specific fix to the note. A pattern of
notes misleading in the same way is a process-level fix to this document or the templates.

## Measurement

The retro compares investigation effort on the first and later features in an area, using
the recorded "Knowledge used" counts. If later features aren't visibly cheaper, **fix the
note template rather than adding more notes.**
