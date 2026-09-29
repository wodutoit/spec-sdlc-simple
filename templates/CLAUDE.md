# CLAUDE.md

> Copy to repo root and fill in. This is what stops an AI relearning your codebase
> every session. Keep it short enough that it stays true.

## What this is

<One paragraph. What this system does and who uses it.>

## Commands

- **Install:** `…`
- **Dev:** `…`
- **Test:** `…`
  - Healthy output: `<exactly what passing looks like, so an agent can tell>`
- **Lint:** `…`
- **Typecheck:** `…`
- **Build:** `…`
- **Migrate:** `…`

## Architecture

<Enough to navigate. Where things live and why they live there. Entry points. The
two or three concepts someone has to hold in their head.>

## Conventions

<Naming, error handling, logging, state management, file layout, import ordering.
Point at exemplar files rather than describing in the abstract:
"follow the error handling in `src/api/orders.ts`".>

## Common mistakes in this codebase

<Things that have actually gone wrong. This section earns its keep faster than any
other. Grow it from review findings — when the same correction happens three times,
it belongs here.>

-

## Do not

<Specific prohibitions for this repo. Files not to touch, patterns not to introduce,
services not to call from here.>

-

## Process

This repo follows `SPEC_SDLC.md`.

- Features live in `specs/NNNN-slug/` with `intent.md`, `spec.md`, `design.md`,
  `BUILD_PLAN.md`, `build/NN-*.md`, `TEST_REPORT.md`.
- The stage's artifact is the handoff. No artifact, no stage completion.
- Review policy: `REVIEW.md`.
- Ask before committing. Ask before opening a PR.
- **The AI never merges a pull request.**
