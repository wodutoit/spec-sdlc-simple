---
name: design
description: Stage 3 of the spec-driven SDLC. Use when spec.md exists, the feature is user-facing, and design.md does not exist — or when the user asks about UI, UX, screens, flows, states, copy, accessibility, visual design, or wants a wireframe, mockup or prototype. Also use to refine brand, colours, fonts, layout or favicon. Produces specs/NNNN-slug/design.md plus stored design artifacts.
---

# Stage 3 — Design

**Goal:** decide what the user sees and touches before code hardens the wrong choice.

**Skip when:** track S, or track M with nothing user-facing.

**Read first:** `spec.md` — especially the functional requirements and §2 accessibility
and platform support.

**Precondition:** `spec.md` §12 reads `Acceptance status: approved`. If it's `draft`, the
acceptance criteria were never approved — stop and send the user back to
`/sdlc:requirements`. (Track S has no spec and is exempt.)

---

## 1. Decide what gets produced — ask, don't assume

Design is the one stage whose output a human has to *look at*. A written description
of a layout is not a layout. So before describing anything, agree what visual
artifacts this feature needs.

**Ask the user**, with `AskUserQuestion`:

| Artifact | What it settles | Pick it when |
|---|---|---|
| **Wireframe** | Structure, hierarchy, where things sit. No colour, no brand | The open question is *what goes on the screen* |
| **Mockup** | The visual: brand, colour, type, spacing applied. Static | The open question is *how it should look* |
| **Prototype** | Flow and interaction. Clickable, stateful | The open question is *how it should feel to use* |
| **None** | Nothing — the existing design system already answers it | The pattern exists and is being reused as-is |

More than one is normal: wireframe to agree structure, then mockup once it's settled.
Recommend based on **what's actually uncertain**, and say why — don't just present the
menu. If the user doesn't know, ask what they're least sure about.

"None" is a legitimate answer and often the right one. Don't manufacture artifacts for
a screen that reuses an existing pattern.

### Also ask which brand decisions are open

Separately from fidelity, find out what is still undecided versus already fixed by an
existing system:

- **Colour** — palette, semantic roles (danger, success), light and dark
- **Typography** — families, scale, weights, licensing
- **Layout** — grid, breakpoints, spacing scale, density
- **Favicon and app icons** — often forgotten until launch; see below
- **Logo** — usage, clear space, variants
- **Iconography** — set, weight, whether it's consistent with the above
- **Motion** — durations, easing, what animates and what must not

Where an existing design system settles one, say so and move on. Only the open ones
need work, and each net-new token needs justifying.

---

## 2. If designs already exist, still ask

Linked or attached mockups, Figma files, a prototype, a brand guide, an existing
screen to match — none of these mean this stage is done. **Ask explicitly** which
applies:

| Option | Meaning |
|---|---|
| **Use as-is** | The existing design covers it. Reference it, produce nothing new |
| **Create new, using it as reference** | New artifacts for this feature, consistent with the existing work |
| **Extend it** | Add to the existing file or system in place |

The default is the middle one, and it is the case most often missed: an existing
design is a *reference*, not a substitute for designing this feature. Ask even when
the user has just handed you a link — especially then.

Where new work and a linked design disagree, record **which is authoritative** and
why. Never let them silently diverge; that's how a build ends up matching neither.

If this session has a design-tool connector available, read the linked file through it
rather than inferring from a screenshot. If not, ask the user for an export rather
than guessing at values — approximated brand colours are worse than absent ones.

---

## 3. Usable and beautiful are two questions

Answer both. "Make it look nice" isn't design.

- **Usable:** what is the shortest path to the thing the user came for? How many
  decisions does it demand? What can be inferred instead of asked?
- **Beautiful:** hierarchy, rhythm, restraint. Reference the existing design system by
  name and reuse it.

## 4. Every state, not just the happy one

This is the section that decides whether the product feels broken. For each screen and
component:

- **Empty** — first run, and after the user deletes everything
- **Loading** — and slow-loading: what happens after 3 seconds?
- **Partial / paginated** — a lot of data, and a little
- **Error** — one entry per error class, with the actual copy
- **Success** — what confirms it worked
- **Disabled / no permission** — what the user sees, and why

A mockup that shows only the populated happy path has not been reviewed properly. Ask
for the empty and error states too, or produce them.

## 5. Write the copy

Actual strings, in a table. Errors say what happened *and* what to do next. Never
"an error occurred."

## 6. Accessibility is part of design, not a retrofit

Keyboard path through every flow. Focus order and a visible focus indicator. Contrast
ratios **measured against the actual palette**, not assumed — this is where a colour
choice made in step 1 gets caught or passes. Screen-reader labels and live regions.
Reduced-motion behaviour. Touch target sizes.

## 7. Favicon and app icons

Small, routinely forgotten, and visible on every tab. If it's in scope, settle it
here: the source mark, the exported sizes, and the dark-background variant. Record the
source file, not only the exports — a 16px PNG can't be regenerated.

---

## 8. Store the artifacts

Design artifacts are part of the spec and belong with it, not in a chat scrollback or
someone's local folder.

```
specs/NNNN-slug/
  design.md                      the stage artifact — describes and indexes
  design/
    wireframes/
    mockups/
    prototype/
    brand/                       palette, type scale, tokens
    icons/                       favicon source + exports
    exports/                     pulled from external tools
```

Then **index every file in `design.md`'s artifact inventory** with: what it is, its
fidelity, its status (draft / approved / superseded), whether it is authoritative, and
where it came from. An unindexed file in `design/` is unreviewable — nobody knows
whether it's current.

Three rules that stop this rotting:

- **Keep the source, not just the output.** An exported PNG you can't edit is a dead
  end. Store the editable source or a link to it.
- **Mark superseded files superseded** rather than deleting them. A build that
  references an old mockup needs to find out it's stale.
- **Large binaries:** if a file is big enough to bloat the repo, store it externally,
  link it in the inventory, and say in the inventory that the external copy is
  authoritative. Don't let the only copy live somewhere that can vanish — and check
  whether the repo uses Git LFS before committing large assets.

Ask before committing, as at every stage.

## 9. Write it

Path: `specs/NNNN-slug/design.md`.
Template: `${CLAUDE_PLUGIN_ROOT}/templates/design.md`.

## Gate

- Artifact fidelity agreed with the user — including a deliberate "none".
- Existing designs: reuse-vs-reference-vs-extend decided, and authority recorded.
- Open brand decisions resolved: colour, type, layout, favicon, logo, icons, motion —
  or marked as settled by the existing system.
- Every user-facing screen and flow described.
- Every state covered for every screen.
- Copy written, including error strings.
- Accessibility section complete, with contrast measured against the real palette.
- Responsive behaviour stated, including what mobile actually looks like.
- Every file in `design/` indexed in the inventory, with one marked authoritative where
  two could conflict.
- Committed (ask first).

Then: stage 4 (`/sdlc:plan`).
