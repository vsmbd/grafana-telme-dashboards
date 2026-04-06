# NONGOALS

This repository is not trying to do everything at once.

For this first milestone, the following are out of scope.

---

## 1. Building a large dashboard suite
The initial goal is not to create 10 or more dashboards.
The current target is exactly 3 dashboards.

## 2. Creating nested Grafana folder structures
Do not create analytics and engineering subfolders yet.
All 3 dashboards must be top-level dashboards inside `Telme`.

## 3. Modeling fake or inflated KPIs
Do not invent metrics that are not naturally supported by the product or telemetry.

## 4. Reworking the full ClickHouse schema
A full schema redesign is out of scope for this repo.

## 5. Solving all observability concerns
This is not a complete tracing, profiling, or production APM replacement effort.

## 6. Overcomplicating the first version
Avoid large panel counts, excessive dashboard sprawl, or speculative metrics.

## 7. Treating function-level timing as already solved
The function performance dashboard may require derived views or additional instrumentation.
Do not assume the raw schema alone already provides everything cleanly.

## 8. Optimizing for every Grafana feature immediately
Alerting, annotations, drilldowns, templating complexity, and advanced provisioning can come later.

## 9. Using screenshots as the only design driver
Screenshots matter, but dashboards must still remain technically credible and queryable.

## 10. Locking the taxonomy forever
This 3-dashboard structure is the starting point, not the final permanent dashboard taxonomy.
