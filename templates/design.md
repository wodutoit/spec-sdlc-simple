# Design: <title>

**Spec:** ./spec.md

## Artifacts produced

What this feature needs a human to look at, agreed before the work started.

| Artifact | Fidelity | Why this fidelity | Status |
|---|---|---|---|
| | wireframe / mockup / prototype | <what was uncertain that this settles> | draft / approved / superseded |

<If the answer was "none — reuses the existing design system", say so here and name the
pattern being reused. A deliberate "none" is a valid outcome; an unanswered question
is not.>

## Existing designs referenced

| Source | Link or path | How it's used | Authoritative? |
|---|---|---|---|
| <Figma file, brand guide, existing screen> | | use as-is / reference for new work / extended in place | yes / no |

<Where new work and a referenced design disagree, exactly one side is authoritative.
Say which, and why. Silent divergence means the build matches neither.>

## Artifact inventory

Every file under `design/`. An unindexed file is unreviewable — nobody can tell whether
it is current.

| File | What it is | Source (editable original) | Status | Authoritative? |
|---|---|---|---|---|
| `design/wireframes/invite-flow.png` | | `design/wireframes/invite-flow.fig` | draft | yes |

<Keep the editable source, not only the export. Mark superseded files superseded rather
than deleting them. If a file is stored externally because of size, say so and note
that the external copy is authoritative.>

## Users and context

<Who uses this, on what device, in what situation, how often, how skilled. A tool
used daily by an expert and a form filled once by a stranger are different designs.>

## Primary flows

For each flow: entry point -> steps -> exit. Name the shortest path to value.

**Flow 1: <name>**
1. …
2. …

## Screens and components

**<Screen name>**
- Purpose:
- Content hierarchy: <what the eye hits first, second, third>
- Primary action:
- Secondary actions:
- Reused from existing system:
- Net new:

## States

Every screen or component, every state. This section is where products stop feeling
broken.

**<Screen name>**
- **Empty** — first run, and after the user deletes everything
- **Loading** — and slow-loading: what happens after 3 seconds?
- **Partial / paginated** — a lot of data, a little data
- **Error** — one entry per error class, with the actual copy
- **Success** — what confirms the action worked
- **Disabled / no permission** — what the user sees and why

## Copy

Exact strings. Labels, buttons, empty states, errors, confirmations.

| Location | String |
|---|---|
| | |

Error messages say what happened and what to do next. Never "an error occurred."

## Visual design

Mark each line **settled** (the existing design system answers it) or **decided here**
(and then give the values). An empty line is an unanswered question.

- **Colour palette:** <values, plus semantic roles — danger, success, warning>
- **Light and dark:** <both, or why only one>
- **Type families:** <names, weights, and the licence for each>
- **Type scale:**
- **Spacing scale:**
- **Grid and breakpoints:**
- **Elevation / borders:**
- **Iconography:** <set, weight, consistency with the type>
- **Motion:** <durations, easing, what animates and what must not>

Reference the existing design system by name. Justify only net-new tokens.

### Logo and favicon

Small, visible everywhere, and routinely left until launch.

| Item | Source file | Exports | Notes |
|---|---|---|---|
| Favicon | `design/icons/favicon.svg` | 16, 32, 180, 512 | dark-background variant? |
| Logo | | | clear space, variants |

Store the **source** mark, not only the exports — a 16px PNG cannot be regenerated.

## Accessibility

- Keyboard path through every flow:
- Focus order and visible focus indicator:
- Contrast ratios: <measured, not assumed>
- Screen-reader labels and live regions:
- Reduced-motion behaviour:
- Touch target sizes:

## Responsive behaviour

- Breakpoints and what changes at each:
- The mobile experience, specifically:

## Open design questions

1.
