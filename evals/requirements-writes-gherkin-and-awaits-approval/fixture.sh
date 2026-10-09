#!/usr/bin/env bash
# Seeds the stage 1 artifact that stage 2 consumes.
set -euo pipefail

D="specs/0004-reports-csv-export"
mkdir -p "$D"

cat > "$D/intent.md" <<'EOF'
# Intent: CSV export for reports

**Originator:** eval fixture   **Date:** 2026-10-09   **Track:** M
**Track reason:** New capability on an existing screen, user-facing, no schema change.

## Problem
Finance analysts copy numbers out of the reports page by hand into spreadsheets, about
twenty times a week, and transcription errors have twice reached month-end figures.

## Proposed outcome
An analyst downloads any report as a CSV that opens correctly in a spreadsheet, with the
same numbers as the screen. Manual copying stops.

## Affected systems
Reports page, reports API.

## Constraints
Reports can hold up to 50,000 rows. Only users who can already view a report may export it.

## Out of scope
Scheduled exports, PDF or Excel formats, emailing exports.

## Open questions
None outstanding.
EOF

cat > CLAUDE.md <<'EOF'
# CLAUDE.md

## What this is
Web application with a reporting module.

## Commands
- Test: `make test` -> healthy output: `All tests passed`

## Process
This repo follows the spec-driven SDLC. Features live in `specs/NNNN-slug/`.
The AI never merges a pull request.
EOF
