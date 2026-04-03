//
//  RemainingDashboards.swift
//  GrafanaDashboardGenerator
//

import Foundation

// MARK: - DashboardDefinitions (remaining dashboards)

extension DashboardDefinitions {

	// MARK: + 01 Product overview

	static func productOverview() -> GrafanaDashboard {
		var y = 0
		var pid = 1
		var panels: [GrafanaPanel] = []
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Unique sessions (from records)",
			sql: """
			SELECT uniqExact(r.session_id) AS value
			FROM records AS r
			WHERE $__timeFilter(r.event_wall_time)
			""",
			x: 0, y: y
		))
		pid += 1
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Total records",
			sql: """
			SELECT count() AS value
			FROM records AS r
			WHERE $__timeFilter(r.event_wall_time)
			""",
			x: 6, y: y
		))
		pid += 1
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Unique installs",
			sql: """
			SELECT uniqExact(s.install_id) AS value
			FROM records AS r
			INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
			WHERE $__timeFilter(r.event_wall_time)
			""",
			x: 12, y: y
		))
		pid += 1
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Distinct app versions",
			sql: """
			SELECT uniqExact(s.app_version) AS value
			FROM records AS r
			INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
			WHERE $__timeFilter(r.event_wall_time)
			""",
			x: 18, y: y
		))
		pid += 1
		y += 4
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Distinct device models",
			sql: """
			SELECT uniqExact(s.device_hardware_model) AS value
			FROM records AS r
			INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
			WHERE $__timeFilter(r.event_wall_time)
			""",
			x: 0, y: y
		))
		pid += 1
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Distinct event kinds",
			sql: """
			SELECT uniqExact(r.kind) AS value
			FROM records AS r
			WHERE $__timeFilter(r.event_wall_time)
			""",
			x: 6, y: y
		))
		pid += 1
		y += 4
		panels.append(DashboardSupport.timeseriesPanel(
			id: pid,
			title: "Active sessions over time ($__interval — bucket in query)",
			sql: """
			SELECT
				toStartOfInterval(r.event_wall_time, INTERVAL 15 MINUTE) AS time,
				uniqExact(r.session_id) AS sessions
			FROM records AS r
			WHERE $__timeFilter(r.event_wall_time)
			GROUP BY time
			ORDER BY time
			""",
			x: 0, y: y, w: 12, h: 8
		))
		pid += 1
		panels.append(DashboardSupport.timeseriesPanel(
			id: pid,
			title: "Records over time",
			sql: """
			SELECT
				toStartOfInterval(r.event_wall_time, INTERVAL 15 MINUTE) AS time,
				count() AS records
			FROM records AS r
			WHERE $__timeFilter(r.event_wall_time)
			GROUP BY time
			ORDER BY time
			""",
			x: 12, y: y, w: 12, h: 8
		))
		pid += 1
		y += 8
		panels.append(DashboardSupport.barchartPanel(
			id: pid,
			title: "Sessions by app version (top 20)",
			sql: """
			SELECT
				s.app_version AS version,
				uniqExact(r.session_id) AS sessions
			FROM records AS r
			INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
			WHERE $__timeFilter(r.event_wall_time)
			GROUP BY s.app_version
			ORDER BY sessions DESC
			LIMIT 20
			""",
			x: 0, y: y, w: 12, h: 8,
			xField: "version", valueField: "sessions"
		))
		pid += 1
		panels.append(DashboardSupport.barchartPanel(
			id: pid,
			title: "Sessions by device model (top 20)",
			sql: """
			SELECT
				s.device_hardware_model AS model,
				uniqExact(r.session_id) AS sessions
			FROM records AS r
			INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
			WHERE $__timeFilter(r.event_wall_time)
			GROUP BY s.device_hardware_model
			ORDER BY sessions DESC
			LIMIT 20
			""",
			x: 12, y: y, w: 12, h: 8,
			xField: "model", valueField: "sessions"
		))
		return DashboardSupport.baseDashboard(
			title: "Product activity overview",
			uid: TelemetryDashboardUID.productOverview.rawValue,
			tags: ["telme", "analytics"],
			panels: panels
		)
	}

	// MARK: + 02 Funnel

	static func userFunnel() -> GrafanaDashboard {
		let sqlStages = """
		SELECT stage, sessions, pct_of_first_stage
		FROM (
			WITH base AS (
			SELECT session_id, kind
			FROM records
			WHERE $__timeFilter(event_wall_time)
			),
			tot AS (SELECT uniqExact(session_id) AS total FROM base)
			SELECT '1_any_telemetry' AS stage, tot.total AS sessions, 100.0 AS pct_of_first_stage
			FROM tot
			UNION ALL
			SELECT '2_checkpoint_family', uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'checkpoint') > 0), if((SELECT total FROM tot) = 0, 0.0, 100.0 * uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'checkpoint') > 0) / (SELECT total FROM tot)) FROM base AS b
			UNION ALL
			SELECT '3_task_queue_family', uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'task') > 0 OR positionCaseInsensitive(b.kind, 'queue') > 0), if((SELECT total FROM tot) = 0, 0.0, 100.0 * uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'task') > 0 OR positionCaseInsensitive(b.kind, 'queue') > 0) / (SELECT total FROM tot)) FROM base AS b
			UNION ALL
			SELECT '4_correlated_suffix', uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'correlated') > 0), if((SELECT total FROM tot) = 0, 0.0, 100.0 * uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'correlated') > 0) / (SELECT total FROM tot)) FROM base AS b
			UNION ALL
			SELECT '5_started_phase', uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'started') > 0), if((SELECT total FROM tot) = 0, 0.0, 100.0 * uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'started') > 0) / (SELECT total FROM tot)) FROM base AS b
			UNION ALL
			SELECT '6_completed_phase', uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'completed') > 0), if((SELECT total FROM tot) = 0, 0.0, 100.0 * uniqExactIf(b.session_id, positionCaseInsensitive(b.kind, 'completed') > 0) / (SELECT total FROM tot)) FROM base AS b
		) AS funnel
		ORDER BY stage
		"""
		let sqlTop = """
		SELECT
			kind,
			uniqExact(session_id) AS sessions,
			count() AS records,
			round(100.0 * uniqExact(session_id) / greatest((SELECT uniqExact(session_id) FROM records WHERE $__timeFilter(event_wall_time)), 1), 2) AS pct_sessions
		FROM records
		WHERE $__timeFilter(event_wall_time)
		GROUP BY kind
		ORDER BY records DESC
		LIMIT 50
		"""
		let note = DashboardSupport.textPanel(
			id: 1,
			title: "",
			content: """
			### Funnel semantics

			This board counts **sessions that emitted at least one** record matching each stage (sequential **subset** funnel: later stages are subsets of earlier ones when stages are nested `kind` sets).

			Stages map to **Telme** `kind` strings (Checkpoint + TaskQueue + domain events when present). Adjust stage SQL if your app emits different `kind` names.

			Domain-specific steps (e.g. seat selection) require matching events in `records.kind` or JSON payloads — see `DASHBOARDS.md`.
			""",
			x: 0, y: 0, w: 24, h: 4
		)
		let panels: [GrafanaPanel] = [
			note,
			DashboardSupport.tablePanel(id: 2, title: "Session reach by stage (approximate kind patterns)", sql: sqlStages, x: 0, y: 4, w: 12, h: 10),
			DashboardSupport.tablePanel(id: 3, title: "Top kinds — session & record coverage", sql: sqlTop, x: 12, y: 4, w: 12, h: 10),
			DashboardSupport.timeseriesPanel(
				id: 4,
				title: "Sessions touching key kind families over time",
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
				x: 0, y: 14, w: 24, h: 8
			),
		]
		return DashboardSupport.baseDashboard(
			title: "User interaction funnel (kind-based)",
			uid: TelemetryDashboardUID.userFunnel.rawValue,
			tags: ["telme", "analytics", "funnel"],
			panels: panels
		)
	}

	// MARK: + 03 Feature adoption

	static func featureAdoption() -> GrafanaDashboard {
		var y = 0
		var pid = 1
		var panels: [GrafanaPanel] = []
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Mean records / session",
			sql: """
			SELECT round(avg(cnt), 2) AS value
			FROM (
				SELECT count() AS cnt
				FROM records
				WHERE $__timeFilter(event_wall_time)
				GROUP BY session_id
			)
			""",
			x: 0, y: y
		))
		pid += 1
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Median records / session",
			sql: """
			SELECT quantileExact(0.5)(cnt) AS value
			FROM (
				SELECT count() AS cnt
				FROM records
				WHERE $__timeFilter(event_wall_time)
				GROUP BY session_id
			)
			""",
			x: 6, y: y
		))
		pid += 1
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Sessions w/ 1+ record",
			sql: """
			SELECT uniqExact(session_id) AS value
			FROM records
			WHERE $__timeFilter(event_wall_time)
			""",
			x: 12, y: y
		))
		pid += 1
		panels.append(DashboardSupport.statPanel(
			id: pid, title: "Sessions w/ 5+ records",
			sql: """
			SELECT countIf(cnt >= 5) AS value
			FROM (
				SELECT session_id, count() AS cnt
				FROM records
				WHERE $__timeFilter(event_wall_time)
				GROUP BY session_id
			)
			""",
			x: 18, y: y
		))
		pid += 1
		y += 4
		panels.append(DashboardSupport.timeseriesPanel(
			id: pid,
			title: "Records per minute (engagement proxy)",
			sql: """
			SELECT
				toStartOfInterval(event_wall_time, INTERVAL 1 MINUTE) AS time,
				count() AS rpm
			FROM records
			WHERE $__timeFilter(event_wall_time)
			GROUP BY time
			ORDER BY time
			""",
			x: 0, y: y, w: 12, h: 7
		))
		pid += 1
		panels.append(DashboardSupport.barchartPanel(
			id: pid,
			title: "Top event kinds by volume",
			sql: """
			SELECT kind, count() AS cnt
			FROM records
			WHERE $__timeFilter(event_wall_time)
			GROUP BY kind
			ORDER BY cnt DESC
			LIMIT 15
			""",
			x: 12, y: y, w: 12, h: 7,
			xField: "kind", valueField: "cnt"
		))
		pid += 1
		y += 7
		panels.append(DashboardSupport.tablePanel(
			id: pid,
			title: "Interaction density distribution (# records per session)",
			sql: """
			SELECT
				cnt AS records_in_session,
				count() AS num_sessions
			FROM (
				SELECT session_id, count() AS cnt
				FROM records
				WHERE $__timeFilter(event_wall_time)
				GROUP BY session_id
			)
			GROUP BY cnt
			ORDER BY cnt
			LIMIT 200
			""",
			x: 0, y: y, w: 24, h: 8
		))
		return DashboardSupport.baseDashboard(
			title: "Feature adoption & engagement",
			uid: TelemetryDashboardUID.featureAdoption.rawValue,
			tags: ["telme", "analytics", "engagement"],
			panels: panels
		)
	}

	// MARK: + 04 Device / OS

	static func deviceOSVersion() -> GrafanaDashboard {
		let panels: [GrafanaPanel] = [
			DashboardSupport.barchartPanel(
				id: 1,
				title: "Sessions by app version",
				sql: """
				SELECT s.app_version AS version, uniqExact(r.session_id) AS sessions
				FROM records r
				INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
				WHERE $__timeFilter(r.event_wall_time)
				GROUP BY s.app_version ORDER BY sessions DESC LIMIT 25
				""",
				x: 0, y: 0, w: 12, h: 9,
				xField: "version", valueField: "sessions"
			),
			DashboardSupport.barchartPanel(
				id: 2,
				title: "Sessions by OS version",
				sql: """
				SELECT s.device_os_version AS osver, uniqExact(r.session_id) AS sessions
				FROM records r
				INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
				WHERE $__timeFilter(r.event_wall_time)
				GROUP BY s.device_os_version ORDER BY sessions DESC LIMIT 25
				""",
				x: 12, y: 0, w: 12, h: 9,
				xField: "osver", valueField: "sessions"
			),
			DashboardSupport.timeseriesPanel(
				id: 3,
				title: "Sessions over time by OS (top 5)",
				sql: """
				SELECT
					toStartOfInterval(r.event_wall_time, INTERVAL 6 HOUR) AS time,
					s.device_os AS os,
					uniqExact(r.session_id) AS sessions
				FROM records r
				INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
				WHERE $__timeFilter(r.event_wall_time)
					AND s.device_os IN (
					SELECT device_os FROM (
						SELECT s2.device_os AS device_os, uniqExact(r2.session_id) c
						FROM records r2
						INNER JOIN (SELECT * FROM app_sessions FINAL) AS s2 ON r2.session_id = s2.session_id
						WHERE $__timeFilter(r2.event_wall_time)
						GROUP BY s2.device_os
						ORDER BY c DESC
						LIMIT 5
					)
					)
				GROUP BY time, s.device_os
				ORDER BY time
				""",
				x: 0, y: 9, w: 24, h: 9
			),
			DashboardSupport.tablePanel(
				id: 4,
				title: "Version × device model (sessions)",
				sql: """
				SELECT
					s.app_version,
					s.device_hardware_model,
					uniqExact(r.session_id) AS sessions
				FROM records r
				INNER JOIN (SELECT * FROM app_sessions FINAL) AS s ON r.session_id = s.session_id
				WHERE $__timeFilter(r.event_wall_time)
				GROUP BY s.app_version, s.device_hardware_model
				ORDER BY sessions DESC
				LIMIT 40
				""",
				x: 0, y: 18, w: 24, h: 9
			),
		]
		return DashboardSupport.baseDashboard(
			title: "Device, OS & version distribution",
			uid: TelemetryDashboardUID.deviceOS.rawValue,
			tags: ["telme", "analytics", "platform"],
			panels: panels
		)
	}

	// MARK: + 05 Session quality

	static func sessionQuality() -> GrafanaDashboard {
		let sqlDur = """
		WITH per AS (
			SELECT
			session_id,
			count() AS records_in_session,
			dateDiff('millisecond', min(event_wall_time), max(event_wall_time)) AS duration_ms
			FROM records
			WHERE $__timeFilter(event_wall_time)
			GROUP BY session_id
		)
		SELECT
			round(avg(records_in_session), 2) AS mean_records,
			quantileExact(0.5)(records_in_session) AS median_records,
			round(avg(duration_ms), 0) AS mean_duration_ms,
			quantileExact(0.5)(duration_ms) AS median_duration_ms,
			max(duration_ms) AS max_duration_ms
		FROM per
		"""
		let panels: [GrafanaPanel] = [
			DashboardSupport.tablePanel(id: 1, title: "Session aggregates (duration = first→last event in range)", sql: sqlDur, x: 0, y: 0, w: 24, h: 4),
			DashboardSupport.barchartPanel(
				id: 2,
				title: "Hour-of-day (UTC) activity — records",
				sql: """
				SELECT
					toString(toHour(event_wall_time)) AS hour_utc,
					count() AS records
				FROM records
				WHERE $__timeFilter(event_wall_time)
				GROUP BY toHour(event_wall_time)
				ORDER BY toHour(event_wall_time)
				""",
				x: 0, y: 4, w: 12, h: 8,
				xField: "hour_utc", valueField: "records"
			),
			DashboardSupport.tablePanel(
				id: 3,
				title: "Day-of-week (UTC) — records",
				sql: """
				SELECT
					toDayOfWeek(event_wall_time) AS dow,
					count() AS records
				FROM records
				WHERE $__timeFilter(event_wall_time)
				GROUP BY dow
				ORDER BY dow
				""",
				x: 12, y: 4, w: 12, h: 8
			),
			DashboardSupport.tablePanel(
				id: 4,
				title: "Busiest sessions (record count)",
				sql: """
				SELECT
					session_id,
					count() AS records_in_session,
					min(event_wall_time) AS first_event,
					max(event_wall_time) AS last_event
				FROM records
				WHERE $__timeFilter(event_wall_time)
				GROUP BY session_id
				ORDER BY records_in_session DESC
				LIMIT 25
				""",
				x: 0, y: 12, w: 24, h: 10
			),
		]
		return DashboardSupport.baseDashboard(
			title: "Session quality & behavioral patterns",
			uid: TelemetryDashboardUID.sessionQuality.rawValue,
			tags: ["telme", "analytics", "sessions"],
			panels: panels
		)
	}

	// MARK: + 06 Pipeline latency

	static func pipelineLatency() -> GrafanaDashboard {
		let filt = """
		$__timeFilter(event_wall_time)
			AND send_mono_nanos >= event_mono_nanos
			AND record_mono_nanos >= event_mono_nanos
			AND send_mono_nanos >= record_mono_nanos
		"""
		let panels: [GrafanaPanel] = [
			DashboardSupport.tablePanel(
				id: 1,
				title: "Latency percentiles (ms, monotonic deltas)",
				sql: """
				SELECT
					quantile(0.50)((record_mono_nanos - event_mono_nanos) / 1e6) AS p50_record_minus_event_ms,
					quantile(0.95)((record_mono_nanos - event_mono_nanos) / 1e6) AS p95_record_minus_event_ms,
					quantile(0.99)((record_mono_nanos - event_mono_nanos) / 1e6) AS p99_record_minus_event_ms,
					quantile(0.50)((send_mono_nanos - record_mono_nanos) / 1e6) AS p50_send_minus_record_ms,
					quantile(0.95)((send_mono_nanos - record_mono_nanos) / 1e6) AS p95_send_minus_record_ms,
					quantile(0.99)((send_mono_nanos - record_mono_nanos) / 1e6) AS p99_send_minus_record_ms,
					quantile(0.50)((send_mono_nanos - event_mono_nanos) / 1e6) AS p50_total_ms,
					quantile(0.95)((send_mono_nanos - event_mono_nanos) / 1e6) AS p95_total_ms,
					quantile(0.99)((send_mono_nanos - event_mono_nanos) / 1e6) AS p99_total_ms,
					max((send_mono_nanos - event_mono_nanos) / 1e6) AS max_total_ms
				FROM records
				WHERE \(filt)
				""",
				x: 0, y: 0, w: 24, h: 5
			),
			DashboardSupport.timeseriesPanel(
				id: 2,
				title: "p50 / p95 total latency (event → send, ms)",
				sql: """
				SELECT
					toStartOfInterval(event_wall_time, INTERVAL 15 MINUTE) AS time,
					quantile(0.50)((send_mono_nanos - event_mono_nanos) / 1e6) AS p50_total_ms,
					quantile(0.95)((send_mono_nanos - event_mono_nanos) / 1e6) AS p95_total_ms
				FROM records
				WHERE \(filt)
				GROUP BY time
				ORDER BY time
				""",
				x: 0, y: 5, w: 24, h: 8,
				unit: "ms"
			),
			DashboardSupport.timeseriesPanel(
				id: 3,
				title: "p95 call-site→record vs record→send (ms)",
				sql: """
				SELECT
					toStartOfInterval(event_wall_time, INTERVAL 15 MINUTE) AS time,
					quantile(0.95)((record_mono_nanos - event_mono_nanos) / 1e6) AS p95_event_to_record_ms,
					quantile(0.95)((send_mono_nanos - record_mono_nanos) / 1e6) AS p95_record_to_send_ms
				FROM records
				WHERE \(filt)
				GROUP BY time
				ORDER BY time
				""",
				x: 0, y: 13, w: 24, h: 8,
				unit: "ms"
			),
		]
		return DashboardSupport.baseDashboard(
			title: "Telemetry pipeline latency overview",
			uid: TelemetryDashboardUID.pipelineLatency.rawValue,
			tags: ["telme", "engineering", "latency"],
			panels: panels
		)
	}

	// MARK: + 07 Latency by kind

	static func latencyByKind() -> GrafanaDashboard {
		let filt = #"""
		$__timeFilter(r.event_wall_time)
			AND r.send_mono_nanos >= r.event_mono_nanos
			AND r.record_mono_nanos >= r.event_mono_nanos
			AND r.send_mono_nanos >= r.record_mono_nanos
			AND match(r.kind, '${kind:regex}')
		"""#
		let sqlTable = """
		SELECT
			r.kind,
			count() AS volume,
			quantile(0.50)((r.send_mono_nanos - r.event_mono_nanos) / 1e6) AS p50_ms,
			quantile(0.95)((r.send_mono_nanos - r.event_mono_nanos) / 1e6) AS p95_ms,
			quantile(0.99)((r.send_mono_nanos - r.event_mono_nanos) / 1e6) AS p99_ms
		FROM records r
		WHERE \(filt)
		GROUP BY r.kind
		ORDER BY p95_ms DESC
		LIMIT 40
		"""
		let sqlTs = """
		SELECT
			toStartOfInterval(r.event_wall_time, INTERVAL 30 MINUTE) AS time,
			quantile(0.95)((r.send_mono_nanos - r.event_mono_nanos) / 1e6) AS p95_ms
		FROM records r
		WHERE \(filt)
		GROUP BY time
		ORDER BY time
		"""
		let panels: [GrafanaPanel] = [
			DashboardSupport.tablePanel(id: 1, title: "Latency by kind (volume + percentiles)", sql: sqlTable, x: 0, y: 0, w: 24, h: 12),
			DashboardSupport.timeseriesPanel(
				id: 2,
				title: "p95 total latency over time (filtered kinds)",
				sql: sqlTs,
				x: 0, y: 12, w: 24, h: 9,
				unit: "ms"
			),
		]
		return DashboardSupport.baseDashboard(
			title: "Latency by event kind",
			uid: TelemetryDashboardUID.latencyByKind.rawValue,
			tags: ["telme", "engineering", "latency"],
			panels: panels,
			extraTemplating: [kindVariable()]
		)
	}

	// MARK: + 08 Session trace

	static func sessionTrace() -> GrafanaDashboard {
		let sql = #"""
		SELECT
			r.record_id,
			r.event_wall_time,
			r.kind,
			(r.record_mono_nanos - r.event_mono_nanos) / 1e6 AS record_minus_event_ms,
			(r.send_mono_nanos - r.record_mono_nanos) / 1e6 AS send_minus_record_ms,
			(r.send_mono_nanos - r.event_mono_nanos) / 1e6 AS total_ms,
			substring(toString(r.correlation), 1, 200) AS correlation_snippet,
			substring(toString(r.event_info), 1, 240) AS event_info_snippet,
			substring(toString(r.event), 1, 240) AS event_snippet
		FROM (SELECT * FROM records FINAL) AS r
		WHERE $__timeFilter(r.event_wall_time)
			AND isValidUUID('${session_id}')
			AND r.session_id = toUUID('${session_id}')
		ORDER BY r.record_id
		"""#
		let panels: [GrafanaPanel] = [
			DashboardSupport.tablePanel(id: 2, title: "Event timeline (monotonic deltas in ms)", sql: sql, x: 0, y: 0, w: 24, h: 16),
		]
		return DashboardSupport.baseDashboard(
			title: "Session trace & event timeline",
			uid: TelemetryDashboardUID.sessionTrace.rawValue,
			tags: ["telme", "engineering", "trace"],
			panels: panels,
			extraTemplating: [sessionVariable()]
		)
	}

	// MARK: + 09 Dedup

	static func dedupReliability() -> GrafanaDashboard {
		let sqlCmp = """
		WITH
			raw AS (SELECT count() AS c FROM records WHERE $__timeFilter(event_wall_time)),
			fin AS (SELECT count() AS c FROM records FINAL WHERE $__timeFilter(event_wall_time))
		SELECT
			raw.c AS raw_row_count,
			fin.c AS final_row_count,
			raw.c - fin.c AS duplicate_candidate_rows
		FROM raw
		CROSS JOIN fin
		"""
		let sqlDups = """
		SELECT
			session_id,
			record_id,
			count() AS row_versions,
			max(send_mono_nanos) - min(send_mono_nanos) AS send_mono_span_ns
		FROM records
		WHERE $__timeFilter(event_wall_time)
		GROUP BY session_id, record_id
		HAVING row_versions > 1
		ORDER BY row_versions DESC
		LIMIT 100
		"""
		let sqlRatio = """
		SELECT
			toStartOfInterval(event_wall_time, INTERVAL 1 HOUR) AS time,
			count() AS raw_rows,
			count() - uniqExact(tuple(session_id, record_id)) AS approx_duplicate_rows
		FROM records
		WHERE $__timeFilter(event_wall_time)
		GROUP BY time
		ORDER BY time
		"""
		let panels: [GrafanaPanel] = [
			DashboardSupport.tablePanel(id: 1, title: "Raw vs FINAL row counts (time filter on event wall time)", sql: sqlCmp, x: 0, y: 0, w: 24, h: 4),
			DashboardSupport.tablePanel(id: 2, title: "(session_id, record_id) groups with multiple versions (retry / resend)", sql: sqlDups, x: 0, y: 4, w: 24, h: 10),
			DashboardSupport.timeseriesPanel(
				id: 3,
				title: "Approx duplicate pressure over time (raw rows − uniq composite)",
				sql: sqlRatio,
				x: 0, y: 14, w: 24, h: 8
			),
		]
		return DashboardSupport.baseDashboard(
			title: "Delivery, retry & dedup (ReplacingMergeTree)",
			uid: TelemetryDashboardUID.dedup.rawValue,
			tags: ["telme", "engineering", "dedup"],
			panels: panels
		)
	}

	// MARK: + 10 Ingestion

	static func ingestionHealth() -> GrafanaDashboard {
		let sqlRows = """
		SELECT
			toStartOfInterval(event_wall_time, INTERVAL 5 MINUTE) AS time,
			count() AS records_inserted
		FROM records
		WHERE $__timeFilter(event_wall_time)
		GROUP BY time
		ORDER BY time
		"""
		let sqlSess = """
		SELECT
			toStartOfInterval(event_wall_time, INTERVAL 5 MINUTE) AS time,
			uniqExact(session_id) AS sessions_touching
		FROM records
		WHERE $__timeFilter(event_wall_time)
		GROUP BY time
		ORDER BY time
		"""
		let sqlPart = """
		SELECT
			partition,
			sum(rows) AS rows,
			formatReadableSize(sum(bytes_on_disk)) AS size
		FROM system.parts
		WHERE database = currentDatabase()
			AND table = 'records'
			AND active
		GROUP BY partition
		ORDER BY partition DESC
		LIMIT 24
		"""
		let sqlBurst = """
		SELECT
			session_id,
			count() AS records_in_range,
			min(event_wall_time) AS first_ev,
			max(event_wall_time) AS last_ev
		FROM records
		WHERE $__timeFilter(event_wall_time)
		GROUP BY session_id
		ORDER BY records_in_range DESC
		LIMIT 25
		"""
		let note = DashboardSupport.textPanel(
			id: 1,
			title: "",
			content: """
			### Storage panels

			`system.parts` requires privileges on the **`system` database**. If panels error, grant access or remove partition/size widgets — **ingestion rate** panels use only `records`.
			""",
			x: 0, y: 0, w: 24, h: 3
		)
		let panels: [GrafanaPanel] = [
			note,
			DashboardSupport.timeseriesPanel(id: 2, title: "Records observed per bucket (proxy for ingest rate)", sql: sqlRows, x: 0, y: 3, w: 12, h: 8),
			DashboardSupport.timeseriesPanel(id: 3, title: "Distinct sessions per bucket", sql: sqlSess, x: 12, y: 3, w: 12, h: 8),
			DashboardSupport.tablePanel(id: 4, title: "Partition rollup — records table (needs system.parts)", sql: sqlPart, x: 0, y: 11, w: 12, h: 9),
			DashboardSupport.tablePanel(id: 5, title: "Heaviest sessions in range", sql: sqlBurst, x: 12, y: 11, w: 12, h: 9),
		]
		return DashboardSupport.baseDashboard(
			title: "Ingestion & storage health",
			uid: TelemetryDashboardUID.ingestion.rawValue,
			tags: ["telme", "engineering", "ingestion"],
			panels: panels
		)
	}
}
