---
name: plan
description: Stage 4 of the spec-driven SDLC. Use when spec.md exists and BUILD_PLAN.md does not, or when the user asks to plan a build, break work into phases, or decide how code will be written. Produces BUILD_PLAN.md (phased checklist) plus build/NN-*.md (detailed per-phase build files). Runs a live impact check on every change and, when enabled, consults and updates code knowledge notes.
---

# Stage 4 — Plan

**Goal:** agree *how* the code gets written, before any of it is written.

**Read first:** `spec.md`, `design.md`, and **the actual codebase**. Read it — don't
assume. Find the patterns you'll be asked to follow and note them by file and line. Where
code knowledge is enabled, start from it (below) instead of from nothing.

**Precondition:** `spec.md` §12 reads `Acceptance status: approved`. If it's `draft`, the
acceptance criteria were never approved — stop and send the user back to
`/sdlc:requirements`. (Track S has no spec and is exempt.)

## Consult code knowledge — before you trace the code

**Read `.claude/spec-sdlc.json` first** — before you open anything under
`.claude/code-knowledge/` — and go on only if `config.codeKnowledge` is `true`. Otherwise **skip this section** —
don't read `.claude/code-knowledge/` even if it exists. If a search turns up its contents
anyway, don't use them; a one-line heads-up that a note exists and wasn't used is fine. The rules are
in `${CLAUDE_PLUGIN_ROOT}/templates/code-knowledge.md`; read it before using a note.

1. **Read `index.md` only.** Match the feature's terms — screens, classes and tables the
   spec names — against its Keywords column. No match means that area is `missing`;
   investigate it normally.
2. **For each matching area,** read its note, run the delta check
   (`git diff --stat <verified_at> HEAD -- <watched_paths>`), classify it, and
   spot-check at least one concrete claim by opening the cited file.
3. **Act on the class:**
   - **fresh** — use it as the starting map and trace only what this feature adds.
   - **partial** — re-investigate only the files that changed.
   - **stale, missing, unverified** — investigate normally. A stale or unverified note is
     a "where to look" hint, never a fact. If you can't run the delta check, the note is
     `unverified`: never call it fresh.
4. **Say one line per note:** used, re-verified in part, or ignored — and why. These go in
   **Knowledge used** in `BUILD_PLAN.md`.
5. **A failed spot-check** marks the note `disputed` (treated as stale) and gets a
   `knowledge-misled` friction entry in Knowledge used. Don't repair the note now; the
   write-back phase proposes the correction.

A missing `.claude/code-knowledge/` folder is not an error — say nothing.

**Notes never make a risk call.** They tell you where to look. They cannot tell you
something is safe, simple or unused, and they have no say in the impact check below.

## The live impact check — in every repo, notes or not

Before you design phases, find out what this change touches. For every file or symbol the
plan creates, modifies or deletes:

1. **Run the impact tool**, if `config.impactTool.command` is set: substitute the changed
   paths for `{paths}` and record the command, the revision, and what it returned. How to
   choose and run one: `${CLAUDE_PLUGIN_ROOT}/templates/impact-tool.md`.
2. **Search the blind spots** — what a tool cannot see: names built from strings,
   reflection, config-driven wiring, schema and SQL coupling, other repos. If the area's
   note lists blind spots, search each listed location. Targeted searches, not a repo scan.
3. **No tool configured?** Fall back to live search for references, importers and callers,
   and mark the check **`tool-less`** — lower confidence, and a reviewer should know. Say
   once that a tool would make this cheaper; don't lecture.
4. **Record it** under **Impact check** in `BUILD_PLAN.md`.
5. **One-way ratchet.** Live findings may **raise** the track or review tier — you find the
   change touches a schema, a public API, or authentication — and then you tell the user
   and re-track. **Nothing may lower them.** "No dependents found" is written as *nothing
   found by this tool and these searches*, never as *there is nothing*.

This check is computed against the proposed change set, live, every time. A note that says
an area is a leaf, simple or unused does not shorten it.

## Two artifacts

**A. `BUILD_PLAN.md`** — the phased checklist. Progress tracker; boxes get ticked in
stage 5. Template: `${CLAUDE_PLUGIN_ROOT}/templates/BUILD_PLAN.md`.

**B. `build/NN-<slug>.md`** — one per phase, the file you'll actually implement
against. Template: `${CLAUDE_PLUGIN_ROOT}/templates/build-phase.md`.

## What makes a phase

A phase is independently verifiable: at the end of it, something runs and you can
tell whether it worked. Each phase gets a **done test** — an exact command, and what
healthy output looks like.

If a phase can only be verified after the next three land, it isn't a phase. Merge it
or re-cut the boundaries.

Order phases so that risk lands early. The thing most likely to invalidate the
approach should be phase 1.

## Interview the engineer

Don't write the plan alone. Ask:

- Which existing patterns should this follow? What should it reuse?
- Where are the landmines in this part of the codebase?
- What order minimizes risk?
- What do you want to review closely versus wave through?
- Anything in the spec you think is wrong?

Iterate on the plan until they approve it. Approval before code is the point of
this stage.

## Writing the per-phase build files

Specific enough that two different engineers would produce substantially the same
code. That means:

- **Files** — a table of what gets created and modified, and why
- **Approach** — prose reasoning and sequence. Signatures and data structures where
  they matter. If you're pasting the whole implementation, pull back: the plan has
  become the code.
- **Patterns to follow** — real references: "mirror `src/api/orders.ts:42-68`"
- **Do not** — specific wrong turns, and why. This section prevents more rework than
  any other.
- **Tests** — what, at what level, asserting what. Include negative cases.
- **Verification** — the exact command and its healthy output.

## Write back what you learned — after the plan is approved

Only when code knowledge is enabled, and only **after** the engineer has approved the
plan. Skip it for a trivial change, or when you found nothing reusable.

1. **Draft the area note and its index row.** Create them from
   `${CLAUDE_PLUGIN_ROOT}/templates/area-note.md` and `knowledge-index.md` if absent.
2. **Record only what you verified in this run.** Bump `verified_at` only for the parts you
   re-verified — never for a note you merely read — and set it to the commit you
   investigated against, not the plan commit. Leave out everything under "what not to
   keep"; above all, the impact check's result.
3. **Propose pruning** while you're in the note: entries not used across several features.
4. **Show the diff and ask once: apply or skip.** Write nothing under
   `.claude/code-knowledge/` before they say apply.
5. **Tell them the files are uncommitted** and need human review. They ride in the plan
   commit below, which you ask about as usual. You never commit on your own.

## Gate

- Engineer has read and approved the plan.
- Every phase has a done test that is an actual command.
- Every phase has a `build/NN-*.md` with no open questions left in it.
- Cross-cutting checklist filled in.
- **Impact check recorded**, with the tool and revision used or an honest `tool-less`.
- **Knowledge used recorded**, if enabled — including any `disputed` note and the
  self-reported effort counts.
- If a write-back was approved, the note and index change are in the plan commit.
- **Committed before implementation starts** — so plan and diff can be compared at
  merge time. Ask first.

Then: stage 5 (`/sdlc:build`).
