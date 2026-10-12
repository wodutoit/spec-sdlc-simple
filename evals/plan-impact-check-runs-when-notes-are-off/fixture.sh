#!/usr/bin/env bash
# A small product repo mid-way through the SDLC: an approved spec for a change to
# monthly_rate, one direct caller, one caller hidden behind a config-driven import, and an
# agent-written code-knowledge note that confidently says nothing depends on the module.
# That note is wrong. The case is whether the plan believes it.
set -euo pipefail

mkdir -p src tests specs/0006-rate-precision .claude/code-knowledge/areas

cat > src/rates.py <<'EOF'
def monthly_rate(annual_pct):
    return annual_pct / 12 / 100
EOF

cat > src/config.py <<'EOF'
# Which module supplies the rate maths is chosen here, not imported by name.
CALC_MODULE = "rates"
EOF

cat > src/loader.py <<'EOF'
import importlib

from src import config


def load_calculator():
    return importlib.import_module(f"src.{config.CALC_MODULE}")
EOF

cat > src/invoice.py <<'EOF'
from src.rates import monthly_rate


def interest_due(balance, apr):
    return balance * monthly_rate(apr)
EOF

cat > tests/test_rates.py <<'EOF'
from src.rates import monthly_rate


def test_monthly_rate():
    assert monthly_rate(12) == 0.01
EOF

cat > specs/0006-rate-precision/intent.md <<'EOF'
# Intent: Exact rate arithmetic

**Track:** M
**Track reason:** Changes an existing function used in billing; no schema change.

## Problem
Interest is computed with binary floating point, so invoices drift by a cent in roughly
one in two hundred accounts. Finance reconciles these by hand each month.

## Proposed outcome
Interest on every invoice is exact to the cent, and reconciliation drift stops.

## Out of scope
Changing how rates are stored.
EOF

cat > specs/0006-rate-precision/spec.md <<'EOF'
# Spec: Exact rate arithmetic

**Status:** accepted
**Decision owners:** product (scope)

## 1. Functional requirements
- FR-1 monthly_rate accepts a Decimal annual percentage and returns a Decimal rounded to
  4 decimal places.
- FR-2 Interest on an invoice is computed from that Decimal value without converting to
  float.

## 7. Automated testing requirements
- The one command: `make test`
- Healthy output: `All tests passed`

## 12. Acceptance criteria

**Acceptance status:** approved
**Approved by:** Priya Raman, product owner
**Approved on:** 2026-10-10
**Approved via:** PR review

```gherkin
Feature: Exact rate arithmetic

  @FR-1
  Scenario: A Decimal rate is returned to four places
    Given an annual percentage of Decimal("12")
    When the monthly rate is calculated
    Then the result is Decimal("0.0100")

  @FR-2
  Scenario: Interest due is exact
    Given a balance of Decimal("1000.00") and an APR of Decimal("12")
    When interest due is calculated
    Then the result is Decimal("10.00") with no float rounding
```
EOF

cat > CLAUDE.md <<'EOF'
# CLAUDE.md

## Commands
- Test: `make test` -> healthy output: `All tests passed`

## Process
This repo follows the spec-driven SDLC. Features live in `specs/NNNN-slug/`.
EOF

cat > .claude/spec-sdlc.json <<'EOF'
{
  "repo": "https://example.invalid/process.git",
  "branch": "release",
  "commit": "0000000000000000000000000000000000000000",
  "pulled": "2026-10-10",
  "config": {
    "retroCadence": "on-demand",
    "protectedBranches": ["main"],
    "testCommand": "make test",
    "defaultReviewTier": 3,
    "codeKnowledge": false,
    "impactTool": { "command": null, "ciReport": null }
  }
}
EOF

cat > .claude/code-knowledge/index.md <<'EOF'
# Code knowledge index

Agent-maintained investigation notes. Verify before trusting. One row per area.

| Area | Summary | Keywords (screens, classes, tables) | Verified at | Status | Note |
|---|---|---|---|---|---|
| rates | Interest and rate arithmetic | monthly_rate, rates, interest, apr | 3f9c2ab | ok | areas/rates.md |
EOF

cat > .claude/code-knowledge/areas/rates.md <<'EOF'
---
area: rates
summary: Interest and rate arithmetic
verified_at: 3f9c2ab
verified_on: 2026-08-14
status: ok
confidence: high
watched_paths:
  - src/rates.py
last_touched_by: specs/0002-late-fees
---

# Rates

## Entry points
| Path | Layer | Role |
|---|---|---|
| src/rates.py | domain | monthly_rate |

## Non-obvious couplings and invariants
- rates.py is a leaf module. Nothing else imports it, so its signature can change freely:
  no importers found (src/rates.py).

## Blind spots
None. Everything is imported by name.

## Look here first
| If the feature is about... | Start at |
|---|---|
| interest or rates | src/rates.py |
EOF
