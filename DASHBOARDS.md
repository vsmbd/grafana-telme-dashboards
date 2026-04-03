# DASHBOARDS

This document defines the initial Grafana dashboard set for the Telme + ClickHouse observability demo.

The goal is to generate a dashboard suite that works for both:
- product and portfolio storytelling
- serious engineering and observability analysis

There should be **10 dashboards total**.
The first **5 dashboards** are product analytics / business-facing.
The last **5 dashboards** are hardcore engineering / systems-facing.

---

## Foldering and ordering

Dashboards should appear in this order in Grafana:

1. Product Activity Overview
2. User Interaction Funnel
3. Feature Adoption and Engagement
4. Device, OS, and Version Distribution
5. Session Quality and Behavioral Patterns
6. Telemetry Pipeline Latency Overview
7. Latency by Event Kind
8. Session Trace and Event Timeline
9. Delivery Reliability, Retry, and Dedup Correctness
10. Ingestion and Storage Health

Suggested Grafana folder structure:
- `Analytics`
- `Engineering`

Dashboards 1–5 belong in `Analytics`.
Dashboards 6–10 belong in `Engineering`.

---

## Data model assumptions

The dashboards are expected to be built primarily on top of these ClickHouse tables:
- `app_sessions`
- `records`

Important fields expected to be available:
- `session_id`
- `install_id`
- `record_id`
- `kind`
- `bundle_id`
- `app_version`
- `device_os`
- `device_os_version`
- `device_hardware_model`
- `device_manufacturer`
- `event_mono_nanos`
- `record_mono_nanos`
- `send_mono_nanos`
- `event_wall_time`
- `event`
- `event_info`
- `correlation`

Where needed, Cursor may generate either:
- direct SQL against base tables
- flattened SQL views
- materialized views for dashboard convenience

The dashboard code should prefer correctness and clarity over over-abstracted query reuse.

---

## Common dashboard conventions

All dashboards should follow these conventions unless there is a strong reason not to:

- Use a dark theme-friendly layout.
- Use UTC consistently unless a strong use case exists for local timezone rendering.
- Use `event_wall_time` as the default Grafana time axis for time-series panels.
- Use monotonic timestamps only for latency and sequence calculations.
- Support a global time picker.
- Prefer variables for `session_id`, `app_version`, `device_os`, `device_hardware_model`, and `kind` where useful.
- Keep panel titles concise and readable.
- Avoid noisy raw JSON unless shown intentionally in detail tables.
- Prefer recruiter-friendly readability for Analytics dashboards.
- Prefer engineering truth and inspectability for Engineering dashboards.

Recommended standard variables:
- `session_id`
- `app_version`
- `device_os`
- `device_hardware_model`
- `kind`
- `bundle_id`

---

# ANALYTICS DASHBOARDS

## 1. Product Activity Overview

### Purpose
Provide a top-level understanding of app usage and telemetry activity.

### Audience
Recruiters, hiring managers, founders, PMs, engineers.

### Key questions answered
- Is the app being used?
- Is telemetry flowing?
- How much activity is occurring over time?
- Which versions and devices are active?

### Suggested panels
- Total sessions
- Total records/events
- Unique installs
- Active app versions
- Active device models
- Sessions over time
- Events over time
- Sessions by app version
- Sessions by device model

### Useful dimensions
- `app_version`
- `device_hardware_model`
- `device_os`
- `bundle_id`

### Notes
This should be one of the cleanest and most polished dashboards in the repo.
It should be easy to screenshot.

---

## 2. User Interaction Funnel

### Purpose
Describe how users move through the seat-selection experience.

### Audience
Product-minded engineers, PMs, hiring managers.

### Key questions answered
- How many sessions progress from launch to interaction?
- Where do sessions drop off?
- How often do users reach seat selection?

### Expected funnel stages
These should map to actual emitted events where possible:
- App launched
- Aircraft list viewed
- Cabin opened
- Zoom interaction started
- Seat tapped
- Seat selected
- Confirmation action, if implemented

### Suggested panels
- Funnel visualization
- Count by stage
- Drop-off by stage
- Funnel conversion percentages
- Stage completion over time

### Notes
Do not fabricate business-style conversion logic if the underlying events do not support it.
Keep this rooted in actual product interactions.

---

## 3. Feature Adoption and Engagement

### Purpose
Show which interactive features are actually being used.

### Audience
Recruiters, PMs, product engineers.

### Key questions answered
- Which interaction types are most common?
- Are users engaging meaningfully or bouncing quickly?
- How interaction-heavy is a typical session?

### Suggested panels
- Zoom usage frequency
- Pan usage frequency
- Seat tap frequency
- Seat selection frequency
- Average interactions per session
- Distribution of interactions per session
- Sessions with no interaction vs engaged sessions
- Top event kinds

### Useful derived metrics
- interactions per session
- selections per session
- percentage of sessions with at least one meaningful interaction

### Notes
This dashboard should feel product-analytics oriented, not marketing vanity analytics.

---

## 4. Device, OS, and Version Distribution

### Purpose
Show where the app is running and how releases are distributed.

### Audience
Platform engineers, EMs, hiring managers.

### Key questions answered
- Which app versions are active?
- Which iOS versions are active?
- Which devices are most common?
- Is the newest version being adopted?

### Suggested panels
- Sessions by app version
- Sessions by OS version
- Sessions by hardware model
- Sessions over time by app version
- Latest-version adoption trend
- Version/device matrix table

### Useful dimensions
- `app_version`
- `device_os`
- `device_os_version`
- `device_hardware_model`

### Notes
This dashboard is useful for showing release awareness and compatibility thinking.

---

## 5. Session Quality and Behavioral Patterns

### Purpose
Summarize session-level behavior and quality characteristics.

### Audience
Product engineers, PMs, hiring managers.

### Key questions answered
- How dense is a typical session?
- When do users engage most?
- What does session behavior look like at a high level?

### Suggested panels
- Average records per session
- Median records per session
- Approximate session duration from first to last event
- Session duration distribution
- Selections per session
- Top active hours of day
- Activity by day of week
- Top session archetypes table

### Notes
Session duration should be derived carefully using first and last event timestamps within a session.
Do not overstate meaning where sample size is small.

---

# ENGINEERING DASHBOARDS

## 6. Telemetry Pipeline Latency Overview

### Purpose
Measure end-to-end telemetry pipeline latency inside the app-side event lifecycle.

### Audience
Senior engineers, performance-minded hiring managers, SRE/platform engineers.

### Key questions answered
- How long does it take to turn an event call-site signal into a record?
- How long does it take to move a record toward send time?
- What is the total event-to-send latency?
- Are latency distributions stable over time?

### Core latency calculations
These should be first-class derived metrics:
- `record_mono_nanos - event_mono_nanos`
- `send_mono_nanos - record_mono_nanos`
- `send_mono_nanos - event_mono_nanos`

### Suggested panels
- p50 call-site to record latency
- p95 call-site to record latency
- p99 call-site to record latency
- p50 record to send latency
- p95 record to send latency
- p99 total event to send latency
- Max total latency
- Latency over time
- Latency heatmap or distribution

### Notes
This is a flagship engineering dashboard.
It should look serious and precise.

---

## 7. Latency by Event Kind

### Purpose
Compare latency behavior across event categories.

### Audience
Engineers and performance reviewers.

### Key questions answered
- Are some event kinds slower than others?
- Are specific event classes driving p95 or p99 spikes?
- Is the system uniformly healthy or selectively degraded?

### Suggested panels
- p50 total latency by `kind`
- p95 total latency by `kind`
- p99 total latency by `kind`
- Event volume by `kind`
- Top slowest event kinds
- Latency vs volume scatter or table
- Time-series latency for selected `kind`

### Useful dimensions
- `kind`
- optionally extracted checkpoint or correlation fields

### Notes
This dashboard helps distinguish systemic latency from workload-specific latency.

---

## 8. Session Trace and Event Timeline

### Purpose
Provide session-level event sequencing and detailed event inspection.

### Audience
Senior engineers, interviewers, platform reviewers.

### Key questions answered
- What happened in one specific session?
- In what order were events emitted, recorded, and sent?
- Where did delays or anomalies occur?

### Suggested panels
- Session selector variable
- Ordered event timeline table by `record_id`
- Event wall time
- Event kind
- Delta from previous event
- `record_mono_nanos - event_mono_nanos`
- `send_mono_nanos - record_mono_nanos`
- `send_mono_nanos - event_mono_nanos`
- correlation / checkpoint details
- raw payload inspector for selected row

### Notes
This dashboard should optimize for inspectability, not executive readability.
It should be one of the strongest screenshots for technical audiences.

---

## 9. Delivery Reliability, Retry, and Dedup Correctness

### Purpose
Show correctness characteristics of a retry-capable pipeline backed by ReplacingMergeTree semantics.

### Audience
Backend engineers, platform reviewers, senior interviewers.

### Key questions answered
- Are duplicate candidates appearing due to retries?
- What does deduped truth look like?
- Are retries controlled or pathological?
- Which sessions or records are most affected?

### Suggested panels
- Raw row count vs deduped row count
- Duplicate candidate count by time
- Duplicate candidate count by session
- Records with multiple versions by `(session_id, record_id)`
- Sessions with repeated sends
- Latest-version row selection examples
- Dedup ratio over time

### Important implementation notes
Queries may need to use:
- `FINAL`
- `argMax(...)`
- grouped latest-row semantics using `send_mono_nanos`

### Notes
This dashboard should clearly reflect that the system is designed for retry tolerance and eventual deduplication.

---

## 10. Ingestion and Storage Health

### Purpose
Track backend ingestion flow and ClickHouse-side operational health.

### Audience
Platform engineers, backend engineers, technically strong hiring managers.

### Key questions answered
- Is ingestion healthy?
- Are rows arriving at expected rates?
- Is storage growing sensibly?
- Are there burst patterns or pressure points?

### Suggested panels
- Rows inserted over time
- Records received per minute
- Sessions received per minute
- Ingestion lag approximation
- Partition growth by month
- Storage footprint by table
- Heavy sessions or burstiest periods
- Error/failed-ingest trends if such signals are emitted

### Notes
This dashboard may require additional backend instrumentation or system tables depending on how deep the repo chooses to go.
Keep scope practical.

---

# Screenshot priorities

If only a subset of dashboards will be used for resume / LinkedIn screenshots, prioritize these four:

1. Product Activity Overview
2. User Interaction Funnel
3. Telemetry Pipeline Latency Overview
4. Session Trace and Event Timeline

Secondary screenshot candidates:
- Device, OS, and Version Distribution
- Latency by Event Kind
- Delivery Reliability, Retry, and Dedup Correctness

---

# Implementation guidance for Cursor

Cursor should generate Grafana JSON with these principles:
- prefer useful and working panels over decorative panels
- keep layouts balanced for screenshot quality
- use clear naming and tags
- produce reusable variables where they materially help
- keep SQL readable and debuggable
- avoid excessive templating or abstraction
- assume this repo is a dashboard repo, not a generalized dashboard framework

Where schema friction exists, Cursor may introduce:
- SQL views
- materialized views
- extracted helper fields

But it should not redesign the full telemetry storage model unless explicitly instructed.
