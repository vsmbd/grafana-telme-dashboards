//
//  GrafanaModels.swift
//  GrafanaDashboardGenerator
//

import Foundation

// MARK: - GrafanaDashboard

/// Root document written to Grafana dashboard JSON.
struct GrafanaDashboard: Codable,
						   Sendable,
						   Equatable {
	var annotations: AnnotationsBox
	var editable: Bool = true
	var fiscalYearStartMonth: Int = 0
	var graphTooltip: Int = 1
	/// Grafana exports `null`; omission is also accepted.
	var id: Int?
	var links: [String] = []
	var liveNow: Bool = false
	var panels: [GrafanaPanel]
	var refresh: String = "30s"
	var schemaVersion: Int = 39
	var style: String = "dark"
	var tags: [String]
	var templating: TemplatingBox
	var time: DashboardTimeRange
	var timepicker: EmptyObject = EmptyObject()
	var timezone: String = "utc"
	var title: String
	var uid: String
	var version: Int = 1
	var weekStart: String = ""
	var description: String?

	enum CodingKeys: String,
					   CodingKey {
		case annotations
		case editable
		case fiscalYearStartMonth
		case graphTooltip
		case id
		case links
		case liveNow
		case panels
		case refresh
		case schemaVersion
		case style
		case tags
		case templating
		case time
		case timepicker
		case timezone
		case title
		case uid
		case version
		case weekStart
		case description
	}
}

// MARK: - Empty / boxes

struct EmptyObject: Codable,
					Sendable,
					Equatable {
	init() {}
}

struct AnnotationsBox: Codable,
					   Sendable,
					   Equatable {
	var list: [String] = []
}

struct TemplatingBox: Codable,
					  Sendable,
					  Equatable {
	var list: [TemplateVariable]
}

struct DashboardTimeRange: Codable,
						   Sendable,
						   Equatable {
	var from: String
	var to: String
}

// MARK: - TemplateVariable

enum TemplateVariable: Codable,
					   Sendable,
					   Equatable {
	case datasource(DatasourceTemplateVariable)
	case query(QueryTemplateVariable)

	// MARK: + Kind

	enum Kind: String,
			   Codable,
			   Sendable {
		case datasource
		case query
	}

	private enum CodingKeys: String,
							 CodingKey {
		case type
	}

	// MARK: + Codable

	init(from decoder: Decoder) throws {
		let c = try decoder.container(keyedBy: CodingKeys.self)
		let type = try c.decode(Kind.self, forKey: .type)
		switch type {
		case .datasource:
			self = .datasource(try DatasourceTemplateVariable(from: decoder))
		case .query:
			self = .query(try QueryTemplateVariable(from: decoder))
		}
	}

	func encode(to encoder: Encoder) throws {
		switch self {
		case .datasource(let v):
			try v.encode(to: encoder)
		case .query(let v):
			try v.encode(to: encoder)
		}
	}
}

struct DatasourceTemplateVariable: Codable,
									 Sendable,
									 Equatable {
	var current: EmptyObject = EmptyObject()
	var hide: Int = 0
	var includeAll: Bool = false
	var label: String
	var multi: Bool = false
	var name: String
	var options: [String] = []
	var query: String
	var refresh: Int
	var regex: String = ""
	var skipUrlSync: Bool = false
	var type: String = "datasource"
}

struct QueryTemplateVariable: Codable,
							  Sendable,
							  Equatable {
	var allValue: String?
	var current: TemplateCurrent
	var datasource: DatasourceRef
	var definition: String = "query"
	var hide: Int = 0
	var includeAll: Bool
	var label: String?
	var multi: Bool
	var name: String
	var options: [String] = []
	var query: String
	var refresh: Int
	var regex: String = ""
	var skipUrlSync: Bool = false
	var sort: Int
	var type: String = "query"
}

struct TemplateCurrent: Codable,
						Sendable,
						Equatable {
	var selected: Bool?
	var text: String
	var value: String
}

// MARK: - DatasourceRef & QueryTarget

struct DatasourceRef: Codable,
					  Sendable,
					  Equatable {
	var type: String
	var uid: String
}

struct QueryTarget: Codable,
					Sendable,
					Equatable {
	var datasource: DatasourceRef
	var editorType: String = "sql"
	var format: Int
	var queryType: String = "sql"
	var rawSql: String
	var refId: String
	var pluginVersion: String = "4.4.0"
}

// MARK: - Shared panel pieces

struct GridPos: Codable,
				Sendable,
				Equatable {
	var h: Int
	var w: Int
	var x: Int
	var y: Int
}

struct PanelLink: Codable,
				  Sendable,
				  Equatable {
	var title: String
	var type: String?
	var url: String
	var targetBlank: Bool = false
	var icon: String?
	var tooltip: String?
}

struct FieldLink: Codable,
				  Sendable,
				  Equatable {
	var title: String
	var url: String
	var targetBlank: Bool = false
}

struct ColorMode: Codable,
				  Sendable,
				  Equatable {
	var mode: String
}

// MARK: - Stat panel

struct StatFieldDefaults: Codable,
						  Sendable,
						  Equatable {
	var unit: String
	var links: [FieldLink]?
}

struct StatFieldConfig: Codable,
						Sendable,
						Equatable {
	var defaults: StatFieldDefaults
	var overrides: [EmptyObject] = []
}

struct StatReduceOptions: Codable,
						  Sendable,
						  Equatable {
	var calcs: [String]
	var fields: String
	var values: Bool
}

struct StatOptions: Codable,
					Sendable,
					Equatable {
	var colorMode: String = "value"
	var graphMode: String = "none"
	var justifyMode: String = "auto"
	var orientation: String = "auto"
	var percentChangeColorMode: String = "standard"
	var reduceOptions: StatReduceOptions
	var showPercentChange: Bool = false
	var textMode: String = "auto"
	var wideLayout: Bool = true
}

struct StatPanel: Codable,
				  Sendable,
				  Equatable {
	var datasource: DatasourceRef
	var fieldConfig: StatFieldConfig
	var gridPos: GridPos
	var id: Int
	var options: StatOptions
	var targets: [QueryTarget]
	var title: String
	var type: String = "stat"
	var links: [PanelLink]?
}

// MARK: - Timeseries panel

struct TSFieldCustom: Codable,
						Sendable,
						Equatable {
	var axisBorderShow: Bool = false
	var axisLabel: String = ""
	var drawStyle: String = "line"
	var fillOpacity: Int = 12
	var lineWidth: Int = 1
	var pointSize: Int = 4
	var showPoints: String = "auto"
	var spanNulls: Bool = false
}

struct TSFieldDefaults: Codable,
						Sendable,
						Equatable {
	var color: ColorMode
	var custom: TSFieldCustom
	var unit: String
	var links: [FieldLink]?
}

struct TSFieldConfig: Codable,
					  Sendable,
					  Equatable {
	var defaults: TSFieldDefaults
	var overrides: [EmptyObject] = []
}

struct TSLegend: Codable,
				 Sendable,
				 Equatable {
	var displayMode: String
	var placement: String
}

struct TSTooltip: Codable,
				  Sendable,
				  Equatable {
	var mode: String
}

struct TSOptions: Codable,
				  Sendable,
				  Equatable {
	var legend: TSLegend
	var tooltip: TSTooltip
}

struct TimeseriesPanel: Codable,
						Sendable,
						Equatable {
	var datasource: DatasourceRef
	var fieldConfig: TSFieldConfig
	var gridPos: GridPos
	var id: Int
	var options: TSOptions
	var targets: [QueryTarget]
	var title: String
	var type: String = "timeseries"
	var links: [PanelLink]?
}

// MARK: - Table panel

struct TableFieldConfig: Codable,
						 Sendable,
						 Equatable {
	var defaults: TableFieldDefaults
	var overrides: [EmptyObject] = []
}

struct TableFieldDefaults: Codable,
						   Sendable,
						   Equatable {
	var links: [FieldLink]?

	init(links: [FieldLink]? = nil) {
		self.links = links
	}
}

struct TableOptions: Codable,
					 Sendable,
					 Equatable {
	var cellHeight: String = "sm"
	var showHeader: Bool = true
	var sortBy: [String] = []
}

struct TablePanel: Codable,
				   Sendable,
				   Equatable {
	var datasource: DatasourceRef
	var fieldConfig: TableFieldConfig
	var gridPos: GridPos
	var id: Int
	var options: TableOptions
	var targets: [QueryTarget]
	var title: String
	var type: String = "table"
	var links: [PanelLink]?
}

// MARK: - Barchart panel

struct BarChartOptions: Codable,
						 Sendable,
						 Equatable {
	var barRadius: Int = 0
	var barWidth: Double = 0.9
	var orientation: String = "horizontal"
	var showValue: String = "auto"
	var stacking: String = "none"
	var xField: String
	var xTickLabelRotation: Int = 0
}

struct BarChartPanel: Codable,
					  Sendable,
					  Equatable {
	var datasource: DatasourceRef
	var fieldConfig: TableFieldConfig
	var gridPos: GridPos
	var id: Int
	var options: BarChartOptions
	var targets: [QueryTarget]
	var title: String
	var type: String = "barchart"
	var links: [PanelLink]?
}

// MARK: - Text panel

struct TextCodeOptions: Codable,
						Sendable,
						Equatable {
	var language: String
	var showLineNumbers: Bool
}

struct TextPanelOptions: Codable,
						 Sendable,
						 Equatable {
	var code: TextCodeOptions
	var content: String
}

struct TextPanel: Codable,
				  Sendable,
				  Equatable {
	var gridPos: GridPos
	var id: Int
	var options: TextPanelOptions
	var title: String
	var transparent: Bool = true
	var type: String = "text"
}

// MARK: - GrafanaPanel

enum GrafanaPanel: Codable,
				   Sendable,
				   Equatable {
	case stat(StatPanel)
	case timeseries(TimeseriesPanel)
	case table(TablePanel)
	case barchart(BarChartPanel)
	case text(TextPanel)

	// MARK: + Kind

	private enum Kind: String,
					   Codable,
					   Sendable {
		case stat
		case timeseries
		case table
		case barchart
		case text
	}

	private enum CodingKeys: String,
							 CodingKey {
		case type
	}

	// MARK: + Codable

	init(from decoder: Decoder) throws {
		let c = try decoder.container(keyedBy: CodingKeys.self)
		let kind = try c.decode(Kind.self, forKey: .type)
		switch kind {
		case .stat:
			self = .stat(try StatPanel(from: decoder))
		case .timeseries:
			self = .timeseries(try TimeseriesPanel(from: decoder))
		case .table:
			self = .table(try TablePanel(from: decoder))
		case .barchart:
			self = .barchart(try BarChartPanel(from: decoder))
		case .text:
			self = .text(try TextPanel(from: decoder))
		}
	}

	func encode(to encoder: Encoder) throws {
		switch self {
		case .stat(let p):
			try p.encode(to: encoder)
		case .timeseries(let p):
			try p.encode(to: encoder)
		case .table(let p):
			try p.encode(to: encoder)
		case .barchart(let p):
			try p.encode(to: encoder)
		case .text(let p):
			try p.encode(to: encoder)
		}
	}
}
