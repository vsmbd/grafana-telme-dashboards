//
//  DashboardDefinitions.swift
//  GrafanaDashboardGenerator
//

import Foundation

// MARK: - DashboardDefinitions

/// All Telme Grafana dashboard definitions (mirrors the retired Python generator).
enum DashboardDefinitions {

	// MARK: + Template variables

	static func kindVariable() -> TemplateVariable {
		.query(QueryTemplateVariable(
			allValue: ".*",
			current: TemplateCurrent(selected: false, text: "All", value: "$__all"),
			datasource: DashboardSupport.clickhouseDS,
			includeAll: true,
			label: "kind",
			multi: true,
			name: "kind",
			query: """
			SELECT kind AS __text, kind AS __value FROM records WHERE $__timeFilter(event_wall_time) GROUP BY kind ORDER BY kind
			""",
			refresh: 1,
			sort: 1
		))
	}

	static func sessionVariable() -> TemplateVariable {
		.query(QueryTemplateVariable(
			allValue: nil,
			current: TemplateCurrent(selected: false, text: "", value: ""),
			datasource: DashboardSupport.clickhouseDS,
			includeAll: false,
			label: "session_id",
			multi: false,
			name: "session_id",
			query: """
			SELECT DISTINCT toString(session_id) AS __text, toString(session_id) AS __value FROM records WHERE $__timeFilter(event_wall_time) ORDER BY __text LIMIT 200
			""",
			refresh: 2,
			sort: 1
		))
	}

	// MARK: + 00 Overview

	static func overview() -> GrafanaDashboard {
		let intro = DashboardSupport.textPanel(
			id: 1,
			title: "",
			content: """
			### Telme overview

			Each tile mirrors the **main signal** from a detailed dashboard. **Click the stat or series** (data link), or use **Open full dashboard →** in the panel menu, to jump there — the time range is kept where supported.
			""",
			x: 0,
			y: 0,
			w: 24,
			h: 3
		)
		let h = 6, w = 12, y0 = 3
		let y1 = y0 + h, y2 = y1 + h, y3 = y2 + h, y4 = y3 + h
		let sqlDedup = """
		WITH
			raw AS (SELECT count() AS c FROM records WHERE $__timeFilter(event_wall_time)),
			fin AS (SELECT count() AS c FROM records FINAL WHERE $__timeFilter(event_wall_time))
		SELECT
			raw.c AS raw_rows,
			fin.c AS final_rows,
			raw.c - fin.c AS duplicate_candidates
		FROM raw
		CROSS JOIN fin
		"""
		var panels: [GrafanaPanel] = [intro]
		func drill(_ p: GrafanaPanel, _ uid: TelemetryDashboardUID) {
			panels.append(DashboardSupport.applyDrillthrough(p, dashboardUID: uid.rawValue))
		}
		drill(DashboardSupport.timeseriesPanel(
			id: 2,
			title: "Product activity — active sessions",
			sql: """
			SELECT
				toStartOfInterval(r.event_wall_time, INTERVAL 15 MINUTE) AS time,
				uniqExact(r.session_id) AS sessions
			FROM records AS r
			WHERE $__timeFilter(r.event_wall_time)
			GROUP BY time
			ORDER BY time
			""",
			x: 0, y: y0, w: w, h: h
		), .productOverview)
		drill(DashboardSupport.timeseriesPanel(
			id: 3,
			title: "Funnel — sessions touching checkpoint vs task families",
			sql: """
			SELECT
				toStartOfInterval(r.event_wall_time, INTERVAL 1 HOUR) AS time,
				uniqExactIf(r.session_id, r.kind LIKE '%CheckpointEvent%' OR r.kind LIKE '%checkpoint%') AS checkpoint_sessions,
				uniqExactIf(r.session_id, r.kind LIKE '%TaskQueue%') AS taskqueue_sessions
			FROM records AS r
			WHERE $__timeFilter(r.event_wall_time)
			GROUP BY time
			ORDER BY time
			""",
			x: 12, y: y0, w: w, h: h
		), .userFunnel)
		drill(DashboardSupport.statPanel(
			id: 4,
			title: "Engagement — mean records / session",
			sql: """
			SELECT round(avg(cnt), 2) AS value
			FROM (
				SELECT count() AS cnt
				FROM records
				WHERE $__timeFilter(event_wall_time)
				GROUP BY session_id
			)
			""",
			x: 0, y: y1, w: w, h: h
		), .featureAdoption)
		drill(DashboardSupport.barchartPanel(
			id: 5,
			title: "Platform — sessions by app version (top 10)",
			sql: """
			SELECT s.app_version AS version, uniqExact(r.session_id) AS sessions
			FROM records r
			INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
			WHERE $__timeFilter(r.event_wall_time)
			GROUP BY s.app_version
			ORDER BY sessions DESC
			LIMIT 10
			""",
			x: 12, y: y1, w: w, h: h,
			xField: "version",
			valueField: "sessions"
		), .deviceOS)
		drill(DashboardSupport.statPanel(
			id: 6,
			title: "Sessions — median records / session",
			sql: """
			SELECT quantileExact(0.5)(cnt) AS value
			FROM (
				SELECT count() AS cnt
				FROM records
				WHERE $__timeFilter(event_wall_time)
				GROUP BY session_id
			)
			""",
			x: 0, y: y2, w: w, h: h
		), .sessionQuality)
		drill(DashboardSupport.timeseriesPanel(
			id: 7,
			title: "Pipeline latency — p50 / p95 total (event → send, ms)",
			sql: """
			SELECT
				toStartOfInterval(event_wall_time, INTERVAL 15 MINUTE) AS time,
				quantile(0.50)((send_mono_nanos - event_mono_nanos) / 1e6) AS p50_total_ms,
				quantile(0.95)((send_mono_nanos - event_mono_nanos) / 1e6) AS p95_total_ms
			FROM records
			WHERE $__timeFilter(event_wall_time)
				AND send_mono_nanos >= event_mono_nanos
				AND record_mono_nanos >= event_mono_nanos
				AND send_mono_nanos >= record_mono_nanos
			GROUP BY time
			ORDER BY time
			""",
			x: 12, y: y2, w: w, h: h,
			unit: "ms"
		), .pipelineLatency)
		drill(DashboardSupport.tablePanel(
			id: 8,
			title: "Latency by kind — top 8 by p95 (ms)",
			sql: """
			SELECT
				r.kind,
				quantile(0.95)((r.send_mono_nanos - r.event_mono_nanos) / 1e6) AS p95_ms
			FROM records r
			WHERE $__timeFilter(r.event_wall_time)
				AND r.send_mono_nanos >= r.event_mono_nanos
				AND r.record_mono_nanos >= r.event_mono_nanos
				AND r.send_mono_nanos >= r.record_mono_nanos
			GROUP BY r.kind
			ORDER BY p95_ms DESC
			LIMIT 8
			""",
			x: 0, y: y3, w: w, h: h
		), .latencyByKind)
		drill(DashboardSupport.statPanel(
			id: 9,
			title: "Session trace — distinct sessions (pick one in detail view)",
			sql: """
			SELECT uniqExact(session_id) AS value
			FROM records
			WHERE $__timeFilter(event_wall_time)
			""",
			x: 12, y: y3, w: w, h: h
		), .sessionTrace)
		drill(DashboardSupport.tablePanel(
			id: 10,
			title: "Dedup — raw vs FINAL row counts",
			sql: sqlDedup,
			x: 0, y: y4, w: w, h: h
		), .dedup)
		drill(DashboardSupport.timeseriesPanel(
			id: 11,
			title: "Ingestion — records per five-minute bucket",
			sql: """
			SELECT
				toStartOfInterval(event_wall_time, INTERVAL 5 MINUTE) AS time,
				count() AS records
			FROM records
			WHERE $__timeFilter(event_wall_time)
			GROUP BY time
			ORDER BY time
			""",
			x: 12, y: y4, w: w, h: h
		), .ingestion)
		return DashboardSupport.baseDashboard(
			title: "Overview",
			uid: TelemetryDashboardUID.overview.rawValue,
			tags: ["telme", "overview"],
			panels: panels,
			description: "Highlights from all Telme dashboards; use data links to drill down."
		)
	}
}
