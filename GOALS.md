# GOALS

This document defines the goals for the Grafana dashboard repo that will sit separately from the core Telme / ingestion repos.

## Primary goal

Create a high-quality Grafana dashboard suite for the Telme + ClickHouse observability stack that is good enough for:
- portfolio presentation
- LinkedIn outreach screenshots
- resume support material
- technical discussion in interviews
- internal engineering demos

## Functional goals

### 1. Produce 10 concrete dashboards
The repo should contain dashboard definitions for exactly 10 initial dashboards:
- 5 product analytics / business-facing dashboards
- 5 hardcore engineering dashboards

### 2. Make the dashboards screenshot-worthy
The dashboards should look polished enough that selected panels can be screenshotted and attached or linked when sending resumes or outreach messages.

### 3. Reflect the real data model
The dashboards should align with the actual ClickHouse telemetry schema and not invent fake metrics that are unsupported by the current event model.

### 4. Highlight the strongest engineering story
The repo must emphasize:
- app instrumentation
- event pipeline latency
- retry tolerance
- dedup correctness
- session-level inspectability
- device/version observability

### 5. Balance readability with technical depth
The first 5 dashboards should be understandable by non-specialists.
The last 5 should be strong enough to impress serious engineers.

### 6. Keep the repo implementation-focused
This repo should be practical and runnable, not a strategy document repository.
The primary output is Grafana dashboard JSON and any supporting SQL or documentation required to make it usable.

### 7. Support iterative evolution
The repo should be structured so that new dashboards, variables, SQL views, or derived metrics can be added without chaos.

### 8. Prefer realistic performance dashboards
The repo should make full use of available monotonic timestamp data to generate meaningful latency dashboards rather than superficial performance claims.

### 9. Be honest about scope
Where backend instrumentation or flattened fields are missing, the repo should either:
- expose the limitation clearly
- add narrow helper views
- defer the feature cleanly

### 10. Be a good input for AI-assisted generation
The repo structure and docs should be clear enough that tools like Cursor can generate or refine dashboard JSON with minimal ambiguity.

## Technical goals

### 1. Use Grafana as the presentation layer
Grafana is the target output environment.
All artifacts should be compatible with managing dashboards as code.

### 2. Use ClickHouse as the primary source
Queries should target ClickHouse directly unless helper views are introduced.

### 3. Prefer correctness over premature optimization
For initial versions, correct and readable queries matter more than over-optimized cleverness.

### 4. Keep SQL inspectable
Generated SQL should be readable by a human and easy to debug.

### 5. Support dashboard variables sensibly
Variables should be added where they materially improve exploration, especially:
- `session_id`
- `app_version`
- `device_os`
- `device_hardware_model`
- `kind`

### 6. Preserve engineering credibility
Dashboards should not feel like fake business intelligence laid over a toy app.
They should feel like a real observability story.

## Portfolio goals

### 1. Make the work easy to explain
A recruiter or hiring manager should be able to understand the high-level story in under a minute.

### 2. Make the work easy to defend technically
A senior engineer should be able to drill into the dashboards and see that the metrics are grounded in the underlying schema.

### 3. Support a credible public-facing demo
The repo should make it easy to show a live or static version of the dashboard suite as part of outreach.

### 4. Showcase engineering taste
The dashboards should communicate that the author cares about:
- data shape
- latency
- sequence integrity
- retry semantics
- platform visibility
- presentation quality

## Success criteria

This repo is successful if:
- 10 dashboards exist and are usable
- at least 4 dashboards are strong enough for screenshot-based outreach
- engineering dashboards feel technically serious
- analytics dashboards feel readable and believable
- the repo is clear enough for future iteration without rework
