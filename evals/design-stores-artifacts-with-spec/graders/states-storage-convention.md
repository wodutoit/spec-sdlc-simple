---
type: llm
---

This process stores design artifacts with the spec, under a specific convention:
`specs/NNNN-slug/design/` (with subfolders such as `wireframes/`, `mockups/`,
`brand/`, `icons/`), and every file gets an inventory row in `design.md` recording its
editable source, status, and whether it is authoritative.

PASS if the response states where the artifacts will be stored, using a path under the
feature's `specs/` directory — for example `specs/0003-workspace-settings/design/`.

PASS also if it says each artifact will be indexed or inventoried in `design.md`, or
that one side must be marked authoritative where the new work and the linked design
could conflict.

Either of those two is enough on its own.

FAIL if the response never says where artifacts would be kept, leaves it implicit, or
proposes somewhere outside the feature's spec directory without reason.

FAIL if it only mentions `design.md` as a document to write, with no indication that
the visual files themselves are stored and tracked.
