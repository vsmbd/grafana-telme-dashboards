//
//  Entry.swift
//  GrafanaDashboardGenerator
//

import Foundation
import JSON

// MARK: - Entry

@main
struct Entry {
	static func main() throws {
		let generatorDir = URL(fileURLWithPath: #filePath)
			.deletingLastPathComponent()
			.deletingLastPathComponent()
		let dashboardsRoot = generatorDir
			.deletingLastPathComponent()
			.appendingPathComponent("dashboards", isDirectory: true)

		// MARK: + Output jobs

		let jobs: [(URL, GrafanaDashboard)] = [
			(dashboardsRoot.appendingPathComponent("overview/overview.json"), DashboardDefinitions.overview()),
			(dashboardsRoot.appendingPathComponent("analytics/product-activity-overview.json"), DashboardDefinitions.productOverview()),
			(dashboardsRoot.appendingPathComponent("analytics/user-interaction-funnel.json"), DashboardDefinitions.userFunnel()),
			(dashboardsRoot.appendingPathComponent("analytics/feature-adoption-engagement.json"), DashboardDefinitions.featureAdoption()),
			(dashboardsRoot.appendingPathComponent("analytics/device-os-version-distribution.json"), DashboardDefinitions.deviceOSVersion()),
			(dashboardsRoot.appendingPathComponent("analytics/session-quality-behavior.json"), DashboardDefinitions.sessionQuality()),
			(dashboardsRoot.appendingPathComponent("engineering/telemetry-pipeline-latency.json"), DashboardDefinitions.pipelineLatency()),
			(dashboardsRoot.appendingPathComponent("engineering/latency-by-event-kind.json"), DashboardDefinitions.latencyByKind()),
			(dashboardsRoot.appendingPathComponent("engineering/session-trace-timeline.json"), DashboardDefinitions.sessionTrace()),
			(dashboardsRoot.appendingPathComponent("engineering/dedup-reliability.json"), DashboardDefinitions.dedupReliability()),
			(dashboardsRoot.appendingPathComponent("engineering/ingestion-storage-health.json"), DashboardDefinitions.ingestionHealth()),
		]

		let encoder = JSONEncoder()
		encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

		for (url, dashboard) in jobs {
			try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
			let jsonValue = try JSON.encode(dashboard, encoder: encoder)
			let data = try jsonValue.toData(prettyPrinted: true)
			try data.write(to: url, options: .atomic)
			print("wrote", url.path)
		}
	}
}
