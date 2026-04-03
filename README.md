# Grafana Dashboard Spec for Telme + ClickHouse

This repo is intended to hold Grafana dashboards for the Telme + ClickHouse observability demo stack.

The purpose is simple:
- generate polished dashboard JSON definitions
- support screenshot-worthy portfolio assets
- provide technically serious engineering dashboards
- keep the dashboards aligned with the actual telemetry schema

This dashboard repo is expected to live separately from the core code repos.

---

## Why this exists

The underlying codebase already has a strong systems story:
- instrumented app-side events
- monotonic and wall-clock timestamps
- structured records
- ClickHouse ingestion
- retry-aware storage semantics
- Grafana as the presentation layer

What is missing is a clean, dedicated dashboard repo that turns that infrastructure into visible artifacts.

That is what this repo is for.

---

## Scope

This repo should contain the initial 10 Grafana dashboards:

### Analytics / product-facing
1. Product Activity Overview
2. User Interaction Funnel
3. Feature Adoption and Engagement
4. Device, OS, and Version Distribution
5. Session Quality and Behavioral Patterns

### Engineering / systems-facing
6. Telemetry Pipeline Latency Overview
7. Latency by Event Kind
8. Session Trace and Event Timeline
9. Delivery Reliability, Retry, and Dedup Correctness
10. Ingestion and Storage Health

The first 5 dashboards should be easy for recruiters, hiring managers, and product-oriented readers to understand.

The last 5 dashboards should be strong enough for serious engineering discussion.

---

## Core design principles

### 1. Truth over theater
The dashboards should be grounded in real telemetry and real schema semantics.

### 2. Polished enough for outreach
At least a subset of dashboards should be visually strong enough for screenshots in resume and LinkedIn outreach.

### 3. Engineering depth matters
The repo should highlight what is actually unusual and strong in the stack:
- latency measurement using monotonic timestamps
- retry and dedup semantics
- session-level sequencing
- platform/version visibility

### 4. Keep it practical
This repo is not a research project and not a dashboard framework product.
It should produce working Grafana assets with minimal ambiguity.

---

## Expected inputs

This repo assumes access to a ClickHouse schema shaped roughly like:
- `app_sessions`
- `records`

Important fields likely include:
- session identifiers
- install identifiers
- record identifiers
- event kind
- app and device metadata
- monotonic timestamps
- wall-clock timestamps
- structured JSON payloads

If helper SQL views or derived fields are required for cleaner dashboards, they may be added here.

---

## Recommended repo contents

Suggested structure:

```text
.
├── README.md
├── DASHBOARDS.md
├── GOALS.md
├── NONGOALS.md
├── dashboards/
│   ├── analytics/
│   └── engineering/
├── sql/
│   ├── views/
│   └── helpers/
└── screenshots/
```

Possible additions later:
- provisioning files
- datasource examples
- dashboard generation scripts
- exported screenshot references

---

## Suggested implementation order

Build dashboards in this order:

1. Product Activity Overview
2. Telemetry Pipeline Latency Overview
3. User Interaction Funnel
4. Session Trace and Event Timeline
5. Device, OS, and Version Distribution
6. Latency by Event Kind
7. Feature Adoption and Engagement
8. Delivery Reliability, Retry, and Dedup Correctness
9. Session Quality and Behavioral Patterns
10. Ingestion and Storage Health

This order gets the highest-value screenshots and technical artifacts early.

---

## Screenshot priorities

If only a few dashboards are turned into polished screenshots at first, prioritize:
- Product Activity Overview
- User Interaction Funnel
- Telemetry Pipeline Latency Overview
- Session Trace and Event Timeline

These four together tell the strongest overall story:
- the app is real
- the behavior is measurable
- the performance is observable
- the system is inspectable

---

## Guidance for Cursor or other AI tooling

When generating Grafana JSONs:
- keep titles clean
- keep layouts balanced
- prefer understandable SQL
- avoid fake KPIs
- use variables where they materially improve exploration
- stay aligned with the actual schema
- add helper views only when they remove real friction

Do not overbuild abstractions.
The purpose of this repo is dashboard output, not framework cleverness.

---

## Related source repos

This dashboard repo is expected to sit alongside code repos in the broader stack, such as:
- app-side instrumentation repos
- Telme core repo
- sink repos
- ingestion-service repo
- ClickHouse schema scripts

This repo should remain presentation-focused while staying faithful to those upstream systems.

---

## Definition of done

This repo is in a good initial state when:
- all 10 dashboard definitions exist
- the dashboards are grouped cleanly into Analytics and Engineering
- the SQL is readable and defensible
- at least 4 dashboards are screenshot-ready
- the engineering dashboards feel technically serious
- the analytics dashboards feel believable and useful
