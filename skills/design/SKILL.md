---
name: design
description: Stage 3 of the spec-driven SDLC. Use when spec.md exists, the feature is user-facing, and design.md does not exist — or when the user asks about UI, UX, screens, flows, states, copy, accessibility, or visual design for a feature. Produces specs/NNNN-slug/design.md.
---

# Stage 3 — Design

**Goal:** decide what the user sees and touches before code hardens the wrong choice.

**Skip when:** track S, or track M with nothing user-facing.

**Read first:** `spec.md` — especially the functional requirements and §2
accessibility and platform support.

## Usable and beautiful are two questions

Answer both. "Make it look nice" isn't design.

- **Usable:** what is the shortest path to the thing the user came for? How many
  decisions does it demand? What can be inferred instead of asked?
- **Beautiful:** hierarchy, rhythm, restraint. Reference the existing design system
  by name and reuse it. Justify only net-new tokens.

## Every state, not just the happy one

This is the section that decides whether the product feels broken. For each screen
and component:

- **Empty** — first run, and after the user deletes everything
- **Loading** — and slow-loading: what happens after 3 seconds?
- **Partial / paginated** — a lot of data, and a little
- **Error** — one entry per error class, with the actual copy
- **Success** — what confirms it worked
- **Disabled / no permission** — what the user sees, and why

## Write the copy

Actual strings, in a table. Errors say what happened *and* what to do next. Never
"an error occurred."

## Accessibility is part of design, not a retrofit

Keyboard path through every flow. Focus order and a visible focus indicator. Contrast
ratios measured, not assumed. Screen-reader labels and live regions. Reduced-motion
behaviour. Touch target sizes.

## Existing design assets

Ask whether mockups or Figma files exist. If they do, reference them and note which
is authoritative when they disagree with this document.

## Write it

Path: `specs/NNNN-slug/design.md`. Template: `${CLAUDE_PLUGIN_ROOT}/templates/design.md`.

## Gate

- Every user-facing screen and flow described.
- Every state covered for every screen.
- Copy written, including error strings.
- Accessibility section complete.
- Responsive behaviour stated, including what mobile actually looks like.
- Committed (ask first).

Then: stage 4 (`/sdlc:plan`).
