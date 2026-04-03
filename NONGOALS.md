# NONGOALS

This document defines what the Grafana dashboard repo is not trying to do.

## 1. It is not trying to be a generic observability platform product
The repo is a focused dashboard repo for a specific Telme + ClickHouse demo stack.
It is not intended to become a full multi-tenant observability SaaS.

## 2. It is not trying to solve every analytics use case
Only dashboards that strongly support the portfolio, demo, and engineering story should be included initially.
This is not a warehouse-scale BI initiative.

## 3. It is not trying to fabricate business KPIs
The repo should not invent revenue-style, growth-style, or product-market-fit style metrics that are unsupported by the current demo app and telemetry model.

## 4. It is not trying to hide schema limitations with fake polish
If the current schema requires helper views or extracted fields for clean dashboards, that should be handled honestly.
Do not create misleading panels that imply unavailable fidelity.

## 5. It is not trying to over-engineer dashboard abstractions
Avoid building a large internal dashboard framework, query DSL, or template engine unless there is a strong and immediate need.

## 6. It is not trying to optimize for every possible scale scenario on day one
Initial dashboard SQL can prioritize correctness, clarity, and demonstrability over hyperscale optimization.

## 7. It is not trying to replace raw engineering inspection tools
Grafana dashboards are the presentation layer.
They do not replace direct SQL investigation, log inspection, or code-level debugging.

## 8. It is not trying to expose every raw field visually
Not every JSON field or payload element needs to appear in the dashboards.
Only fields that help explain product behavior, latency, reliability, or system health should be surfaced.

## 9. It is not trying to be backend-monitoring perfection immediately
If certain ingestion-health or storage-health panels require additional instrumentation or system-table work, those can be added incrementally.

## 10. It is not trying to make non-technical dashboards dominate the story
The analytics dashboards are important, but the repo should still feel engineering-led.
This should not drift into a purely PM-style analytics artifact.

## 11. It is not trying to redesign the telemetry schema by default
The dashboard repo may introduce helper SQL views or derived fields, but it should not assume a wholesale redesign of the underlying ingestion/storage model.

## 12. It is not trying to produce perfect metrics from incomplete event taxonomy
If certain user flows or performance signals are not emitted yet, the correct response is to note the gap or add instrumentation later, not to fake completeness.

## 13. It is not trying to maximize dashboard count
More dashboards are not automatically better.
The initial set should remain tightly curated and defensible.

## 14. It is not trying to produce unreadable “engineering theater”
The engineering dashboards should be deep, but still understandable by competent reviewers.
Depth is the goal, not unnecessary complexity.

## 15. It is not trying to make screenshots at the expense of truth
The dashboards should look good, but visual polish must not come at the cost of misleading queries or dishonest interpretation.
