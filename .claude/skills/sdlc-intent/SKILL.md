---
name: sdlc-intent
description: Stage 1 of the spec-driven SDLC. Use when the user has a new idea, feature request, problem, bug, or incident finding and no intent.md exists yet. Interviews to find the problem under the proposed solution, picks a size track, and writes specs/NNNN-slug/intent.md.
---

# Stage 1 — Intent

**Goal:** get the idea into version control before solutioning distorts it.

## Interview, don't transcribe

The user will describe a solution. Your job is to find the problem underneath it.
Ask roughly in this order, one or two at a time — not as a form:

1. What is happening today that shouldn't be, or not happening that should?
2. Who feels this? How often, and what do they do instead right now?
3. If this were solved, what would be observably different? Push for something
   measurable. "Users would be happier" is not an outcome.
4. What systems, teams, or data does this touch?
5. What's deliberately out of scope?
6. What don't we know yet?

When the user answers with a technology ("we need a queue"), accept it as a clue and
ask what problem it solves. Technology decisions belong in stage 2, section 5.

## Then propose a track

| Track | When |
|---|---|
| **S** | Bug fix, copy change, dependency bump, refactor with no behaviour change |
| **M** | New endpoint, new screen, change to an existing feature's behaviour |
| **L** | New product or subsystem, or anything with a migration |

Forced to **L** regardless of size:
- touches authentication, authorization, secrets, payments, or personal data
- changes a database schema or a public API contract

State the track and a one-line reason. Get agreement before writing.

On track S, `intent.md` can be three lines — problem, outcome, track. Don't make
small work expensive.

## Write it

Path: `specs/NNNN-slug/intent.md` — next unused four-digit sequence, kebab-case slug.
Template: `templates/intent.md` in the spec-sdlc-simple repo, or the skeleton in
`SPEC_SDLC.md` stage 1.

## Gate

- Problem and outcome each fit in one paragraph.
- Neither contains implementation detail.
- Track agreed and recorded.
- Every open question has a named owner.
- Committed (ask first).

Then: stage 2 (`sdlc-requirements`), or stage 5 if track S.
