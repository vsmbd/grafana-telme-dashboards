# Grafana Dashboard Spec for Telme

This repository defines the first Grafana dashboard set for the Telme + ClickHouse environment.

The current milestone intentionally keeps the scope tight.

## Current dashboard scope

There are exactly 3 dashboards in the initial set:

1. Device, OS & Version Distribution
2. Product Activity Overview
3. All Functions Called & Their Average Execution Time

## Grafana folder requirement

All 3 dashboards must appear directly inside a single Grafana folder named:

`Telme`

The expected Grafana Dashboards layout is:

```text
Dashboards
└── Telme
    ├── Device, OS & Version Distribution
    ├── Product Activity Overview
    └── All Functions Called & Their Average Execution Time
```

There should be no nested subfolders for this first iteration.

## Why this repo exists

The main application and telemetry repos already exist separately.
This repo isolates the dashboard layer so it can be:
- generated independently
- version controlled cleanly
- iterated without touching the core application repos
- used for screenshots, demos, and hiring outreach

## Dashboard summary

### 1. Device, OS & Version Distribution
Overview dashboard focused on platform mix and version rollout visibility.

### 2. Product Activity Overview
Overview dashboard focused on sessions, events, and top-level telemetry activity.

### 3. All Functions Called & Their Average Execution Time
Engineering dashboard focused on function-level instrumentation and performance.

## Design philosophy

- Keep the first version small
- Prefer clarity over dashboard sprawl
- Make the overviews readable in seconds
- Make the engineering dashboard technically meaningful
- Keep all dashboards together in a single `Telme` folder
- Expand later only after these 3 are solid

## Suggested repo structure

```text
.
├── dashboards/
├── generator/
├── DASHBOARDS.md
├── GOALS.md
├── NONGOALS.md
└── README.md
```

## Important implementation note

The third dashboard requires function-level timing telemetry that is queryable by:
- function name
- execution duration
- time series window

If the raw schema does not expose this cleanly yet, use derived ClickHouse views or add instrumentation support before finalizing that dashboard.

## Recommended build order

1. Product Activity Overview
2. Device, OS & Version Distribution
3. All Functions Called & Their Average Execution Time

## Related documents

- `DASHBOARDS.md`
- `GOALS.md`
- `NONGOALS.md`
