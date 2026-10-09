#!/usr/bin/env bash
# Seeds a signed-off spec so Stage 3 has its input. Without this the agent stops on
# the missing spec — correct behaviour, but it never reaches what this case tests.
set -euo pipefail

D="specs/0003-workspace-settings"
mkdir -p "$D"

cat > "$D/intent.md" <<'EOF'
# Intent: Workspace member management

**Originator:** eval fixture   **Date:** 2026-10-09   **Track:** M
**Track reason:** New screen, changes an existing feature's behaviour, user-facing.

## Problem
Workspace admins cannot see who has access to their workspace or change anyone's
role without asking support. Support handles roughly 15 such requests a week, each
taking a day to turn around.

## Proposed outcome
Admins manage their own members. Support requests of this kind drop to near zero.

## Affected systems
Web app, workspace service, audit log.

## Out of scope
Billing seats, SSO group mapping, cross-workspace transfers.

## Open questions
None outstanding.
EOF

cat > "$D/spec.md" <<'EOF'
# Spec: Workspace member management

**Status:** accepted
**Intent:** ./intent.md
**Decision owners:** product (scope), security (roles)

## 1. Functional requirements
- FR-1 An admin can list all members with name, email, role and last active date.
- FR-2 An admin can invite a member by email, choosing a role.
- FR-3 An admin can change a member's role.
- FR-4 An admin can remove a member; removal is immediate.
- FR-5 Every change writes an audit log entry.
- FR-6 An admin cannot remove or demote the last remaining admin.

## 2. Non-functional requirements
- Performance: list renders under 300ms for 500 members.
- Scale: up to 5,000 members per workspace.
- Accessibility: WCAG 2.2 AA.
- Platform support: evergreen desktop browsers, plus mobile web.
- Localization: en-GB and de-DE at launch; dates localised.

## 3. Security
- Authorization: workspace admin only; resource-level check on every mutation.
- Data classification: internal, contains member email addresses (PII).
- Audit logging: actor, target, old and new role, timestamp. Never log tokens.

## 4. Governance and compliance
- Regulatory scope: GDPR — member email is personal data.
- Review tier: 1 — changes access control.

## 6. Data and interfaces
- `GET /workspaces/:id/members`, `POST /members`, `PATCH /members/:id`,
  `DELETE /members/:id`.

## 7. Automated testing requirements
- The one command: `make test`
- Healthy output: `All tests passed`

## 12. Acceptance criteria
- [ ] Admin sees every member with role and last active date.
- [ ] Role change takes effect immediately and is audit logged.
- [ ] Removing the last admin is refused with a clear message.
- [ ] Whole flow is operable by keyboard alone.

## Design references
Existing design system: https://figma.example.com/file/abc123/our-design-system
EOF

cat > CLAUDE.md <<'EOF'
# CLAUDE.md

## What this is
Web application. Workspace collaboration product.

## Commands
- Test: `make test` -> healthy output: `All tests passed`

## Process
This repo follows the spec-driven SDLC. Features live in `specs/NNNN-slug/`.
The AI never merges a pull request.
EOF
