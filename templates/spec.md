# Spec: <title>

**Status:** draft | in review | accepted
**Intent:** ./intent.md
**Decision owners:** <who signs off on what>

> Every section gets an answer or an explicit `N/A because…`. A blank section is an
> unanswered question wearing a disguise.

## 1. Functional requirements

Numbered, testable, each independently verifiable.

- **FR-1** …
- **FR-2** …

## 2. Non-functional requirements

- **Performance:** <latency/throughput targets, and at what load>
- **Scale:** <expected volume now, and in 12 months>
- **Availability:** <target, and what "degraded" looks like>
- **Accessibility:** <standard, e.g. WCAG 2.2 AA>
- **Platform support:** <browsers, devices, OS versions>
- **Localization:** <languages, timezones, currency, date formats>

## 3. Security

- **Authentication:** <how users prove identity>
- **Authorization:** <who may do what; resource-level checks to prevent IDOR>
- **Data classification:** <public / internal / confidential / restricted>
- **PII or PHI:** <yes/no — if yes, which fields and what handling>
- **Secrets needed:** <what, and which secrets manager holds them — never hardcoded>
- **Threats considered:** <the ones that actually apply here, not a generic recital>
- **Input validation:** <where the trust boundary is, what validates at it>
- **Output encoding:** <contexts: HTML, SQL, shell, logs, URLs>
- **Audit logging:** <what gets logged; what must never be logged>
- **Applicable standards:** <org standards consulted, with reference>

## 4. Governance and compliance

- **Regulatory scope:** <GDPR / PCI / HIPAA / SOC 2 / none>
- **Data residency:** <where data may live>
- **Retention and deletion:** <how long, and how it gets deleted>
- **Approvals required before release:** <who, for what>
- **Review tier:** <1 critical / 2 high / 3 standard / 4 low>

## 5. Tech stack decisions

| Decision | Choice | Rejected alternatives | Rationale |
|---|---|---|---|
| | | | |

New dependencies — pin versions, check CVEs, check licence compatibility:

| Package | Version | Licence | CVE check | Why this one |
|---|---|---|---|---|
| | | | | |

## 6. Data and interfaces

- **Schema changes:** <tables, columns, indexes>
- **Migration plan:** <order of operations>
- **Migration reversibility:** <how we roll back, specifically>
- **API contracts:** <endpoints, request/response shapes, status codes>
- **Versioning / breaking-change policy:**
- **Events published or consumed:**
- **Third-party integrations:** <what, auth method, failure behaviour>

## 7. Automated testing requirements

- **Unit:** <what must be covered; any threshold>
- **Integration:** <which boundaries get real tests — data access, APIs, queues>
- **End-to-end:** <which user journeys>
- **Security tests:** <invalid token, expired session, unauthorized access, injection
  payloads, boundary conditions — required for anything Tier 1>
- **Performance tests:** <if any, against what target>
- **Fixtures and test data:** <synthetic only; where it lives>
- **The one command:** `<e.g. make test>`
- **Healthy output:** <what passing looks like, exactly — so an agent can tell>

## 8. Local development environment

- **Containers needed:** <yes/no; which services>
- **Clone to running:** <the actual steps>
- **Seed / fixture data:** <how a developer gets useful data>
- **Cannot be run locally:** <what, and how it's covered instead>

## 9. Deployment and CI/CD

- **Pipeline stages:** <build, test, SAST, SCA, deploy>
- **Environments and promotion path:**
- **Feature flag or dark launch:** <yes/no; flag name>
- **Migration ordering vs. code deploy:** <which goes first, and why>
- **Rollback procedure:** <specific steps, not "revert">
- **Monitoring and alerting to add:** <what signals tell us this is broken>
- **Runbook updates needed:**

## 10. Observability

- **Metrics:** <what to emit>
- **Logs:** <what to log; what must never appear>
- **Traces:** <spans worth having>
- **Dashboards / alerts:** <what gets watched>

## 11. Risks and open questions

| # | Risk or question | Owner | Resolution | Status |
|---|---|---|---|---|
| 1 | | | | open |

## 12. Acceptance criteria

The checklist that says this feature is done. Each line maps to an FR.

- [ ] <criterion>
- [ ] <criterion>
