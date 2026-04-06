# DASHBOARDS

This document defines the initial Grafana dashboard set for the Telme + ClickHouse environment.

For now, the dashboard suite is intentionally small and focused. It contains exactly 3 dashboards.

All 3 dashboards must appear as top-level dashboards inside a single Grafana folder named:

`Telme`

There should be no nested Grafana subfolders for this first iteration.

---

## Grafana folder requirement

### Folder name
`Telme`

### Placement rule
All 3 dashboards must be placed directly inside the `Telme` folder in Grafana's Dashboards section.

### Required dashboard list
1. Device, OS & Version Distribution
2. Product Activity Overview
3. All Functions Called & Their Average Execution Time

---

# 1. Device, OS & Version Distribution

## Type
Overview

## Purpose
Show the platform mix of application sessions across app versions, OS versions, and device models.

## Audience
Recruiters, hiring managers, engineering managers, mobile engineers

## What this dashboard should prove
The app is running across real platform combinations and the telemetry captures session metadata cleanly enough to analyze rollout and device distribution.

## Required panels
- Total sessions
- Sessions by app version
- Sessions by OS version
- Sessions by device model
- Latest build adoption over time
- Top version + device combinations

## Data assumptions
This dashboard should primarily use session-level metadata from `app_sessions`.

## Notes
This is a top-level overview dashboard. It should be visually simple and immediately understandable.

---

# 2. Product Activity Overview

## Type
Overview

## Purpose
Provide a fast top-level view of product usage and telemetry activity.

## Audience
Recruiters, hiring managers, founders, PMs, engineers

## What this dashboard should prove
The app is real, instrumented, and generating measurable activity over time.

## Required panels
- Total sessions
- Total events
- Sessions over time
- Events over time
- Average events per session
- Top event kinds

## Data assumptions
This dashboard should primarily use `records`, with optional use of `app_sessions` for ratios or summaries.

## Notes
This should feel like the most general-purpose overview dashboard in the set.

---

# 3. All Functions Called & Their Average Execution Time

## Type
Engineering

## Purpose
Show which instrumented functions are being called and how long they take on average.

## Audience
Senior engineers, staff engineers, engineering managers

## What this dashboard should prove
The instrumentation goes beyond generic event logging and can surface function-level runtime behavior and performance characteristics.

## Required panels
- Total function calls
- Unique functions observed
- Top functions by call count
- Average execution time by function
- p95 execution time by function
- Slowest functions by average duration
- Function execution time trend over time

## Data assumptions
This dashboard requires telemetry that exposes:
- function name
- function execution duration or equivalent timing signal
- sufficient event structure to aggregate by function identity

## Notes
If function-level timing is not yet directly queryable from the current schema, this dashboard should be treated as a target dashboard and supported by derived views or additional instrumentation.

---

## Dashboard IDs / filenames

Use these identifiers for consistency:
- `device-os-version-distribution`
- `product-activity-overview`
- `function-call-performance`

---

## Recommended build order

1. Product Activity Overview
2. Device, OS & Version Distribution
3. All Functions Called & Their Average Execution Time

---

## Sidebar / folder expectation in Grafana

The Grafana Dashboards section should show:

- Telme
  - Device, OS & Version Distribution
  - Product Activity Overview
  - All Functions Called & Their Average Execution Time
