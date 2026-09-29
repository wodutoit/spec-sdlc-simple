# Design: <title>

**Spec:** ./spec.md

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

- Type scale:
- Colour tokens:
- Spacing scale:
- Elevation / borders:
- Motion: <durations, easing, what animates and what must not>

Reference the existing design system by name. Justify only net-new tokens.

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

## Assets

<Mockups, prototypes, Figma links. Note which is authoritative when they disagree.>

## Open design questions

1.
