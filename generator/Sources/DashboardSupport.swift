import Foundation

enum TelemetryDashboardUID: String, Sendable {
    case productOverview = "telme-analytics-product-overview"
    case userFunnel = "telme-analytics-user-funnel"
    case featureAdoption = "telme-analytics-feature-adoption"
    case deviceOS = "telme-analytics-device-os-version"
    case sessionQuality = "telme-analytics-session-quality"
    case pipelineLatency = "telme-eng-pipeline-latency"
    case latencyByKind = "telme-eng-latency-by-kind"
    case sessionTrace = "telme-eng-session-trace"
    case dedup = "telme-eng-dedup-reliability"
    case ingestion = "telme-eng-ingestion-health"
    case overview = "telme-overview"
}

enum DashboardSupport {
    static let clickhouseDS = DatasourceRef(type: "grafana-clickhouse-datasource", uid: "${datasource}")

    static func chTarget(sql: String, refId: String = "A", format: Int = 0) -> QueryTarget {
        QueryTarget(datasource: clickhouseDS, format: format, rawSql: sql, refId: refId)
    }

    static func datasourceVariable() -> TemplateVariable {
        .datasource(DatasourceTemplateVariable(
            label: "ClickHouse",
            name: "datasource",
            query: "grafana-clickhouse-datasource",
            refresh: 1
        ))
    }

    static func baseDashboard(
        title: String,
        uid: String,
        tags: [String],
        panels: [GrafanaPanel],
        extraTemplating: [TemplateVariable] = [],
        description: String? = nil
    ) -> GrafanaDashboard {
        var list: [TemplateVariable] = [datasourceVariable()]
        list.append(contentsOf: extraTemplating)
        return GrafanaDashboard(
            annotations: AnnotationsBox(),
            panels: panels,
            tags: tags,
            templating: TemplatingBox(list: list),
            time: DashboardTimeRange(from: "now-7d", to: "now"),
            title: title,
            uid: uid,
            description: description
        )
    }

    private static let drillTooltip =
        "Opens the detailed dashboard for this area; keeps the selected time range."

    static func drillURL(dashboardUID: String) -> String {
        "/d/\(dashboardUID)?${__url_time_range}"
    }

    static func withDrillthrough(_ panel: StatPanel, dashboardUID: String) -> StatPanel {
        let url = drillURL(dashboardUID: dashboardUID)
        var p = panel
        p.links = [
            PanelLink(title: "Open full dashboard →", type: "link", url: url, targetBlank: false, icon: "dashboard", tooltip: drillTooltip),
        ]
        p.fieldConfig = StatFieldConfig(
            defaults: StatFieldDefaults(unit: p.fieldConfig.defaults.unit, links: [
                FieldLink(title: "Open full dashboard", url: url, targetBlank: false),
            ]),
            overrides: []
        )
        return p
    }

    static func withDrillthrough(_ panel: TimeseriesPanel, dashboardUID: String) -> TimeseriesPanel {
        let url = drillURL(dashboardUID: dashboardUID)
        var p = panel
        p.links = [
            PanelLink(title: "Open full dashboard →", type: "link", url: url, targetBlank: false, icon: "dashboard", tooltip: drillTooltip),
        ]
        var d = p.fieldConfig.defaults
        d.links = [FieldLink(title: "Open full dashboard", url: url, targetBlank: false)]
        p.fieldConfig = TSFieldConfig(defaults: d, overrides: [])
        return p
    }

    static func withDrillthrough(_ panel: TablePanel, dashboardUID: String) -> TablePanel {
        let url = drillURL(dashboardUID: dashboardUID)
        var p = panel
        p.links = [
            PanelLink(title: "Open full dashboard →", type: "link", url: url, targetBlank: false, icon: "dashboard", tooltip: drillTooltip),
        ]
        p.fieldConfig = TableFieldConfig(
            defaults: TableFieldDefaults(links: [
                FieldLink(title: "Open full dashboard", url: url, targetBlank: false),
            ]),
            overrides: []
        )
        return p
    }

    static func withDrillthrough(_ panel: BarChartPanel, dashboardUID: String) -> BarChartPanel {
        let url = drillURL(dashboardUID: dashboardUID)
        var p = panel
        p.links = [
            PanelLink(title: "Open full dashboard →", type: "link", url: url, targetBlank: false, icon: "dashboard", tooltip: drillTooltip),
        ]
        p.fieldConfig = TableFieldConfig(
            defaults: TableFieldDefaults(links: [
                FieldLink(title: "Open full dashboard", url: url, targetBlank: false),
            ]),
            overrides: []
        )
        return p
    }

    static func statPanel(
        id: Int,
        title: String,
        sql: String,
        x: Int,
        y: Int,
        w: Int = 6,
        h: Int = 4
    ) -> GrafanaPanel {
        .stat(StatPanel(
            datasource: clickhouseDS,
            fieldConfig: StatFieldConfig(
                defaults: StatFieldDefaults(unit: "short", links: nil),
                overrides: []
            ),
            gridPos: GridPos(h: h, w: w, x: x, y: y),
            id: id,
            options: StatOptions(
                reduceOptions: StatReduceOptions(calcs: ["lastNotNull"], fields: "", values: false)
            ),
            targets: [chTarget(sql: sql, format: 0)],
            title: title,
            links: nil
        ))
    }

    static func timeseriesPanel(
        id: Int,
        title: String,
        sql: String,
        x: Int,
        y: Int,
        w: Int,
        h: Int,
        unit: String = "short"
    ) -> GrafanaPanel {
        .timeseries(TimeseriesPanel(
            datasource: clickhouseDS,
            fieldConfig: TSFieldConfig(
                defaults: TSFieldDefaults(
                    color: ColorMode(mode: "palette-classic"),
                    custom: TSFieldCustom(),
                    unit: unit,
                    links: nil
                ),
                overrides: []
            ),
            gridPos: GridPos(h: h, w: w, x: x, y: y),
            id: id,
            options: TSOptions(
                legend: TSLegend(displayMode: "list", placement: "bottom"),
                tooltip: TSTooltip(mode: "single")
            ),
            targets: [chTarget(sql: sql, format: 1)],
            title: title,
            links: nil
        ))
    }

    static func tablePanel(
        id: Int,
        title: String,
        sql: String,
        x: Int,
        y: Int,
        w: Int,
        h: Int
    ) -> GrafanaPanel {
        .table(TablePanel(
            datasource: clickhouseDS,
            fieldConfig: TableFieldConfig(defaults: TableFieldDefaults(), overrides: []),
            gridPos: GridPos(h: h, w: w, x: x, y: y),
            id: id,
            options: TableOptions(),
            targets: [chTarget(sql: sql, format: 0)],
            title: title,
            links: nil
        ))
    }

    static func barchartPanel(
        id: Int,
        title: String,
        sql: String,
        x: Int,
        y: Int,
        w: Int,
        h: Int,
        xField: String,
        valueField: String
    ) -> GrafanaPanel {
        .barchart(BarChartPanel(
            datasource: clickhouseDS,
            fieldConfig: TableFieldConfig(defaults: TableFieldDefaults(), overrides: []),
            gridPos: GridPos(h: h, w: w, x: x, y: y),
            id: id,
            options: BarChartOptions(xField: xField),
            targets: [chTarget(sql: sql, format: 0)],
            title: title,
            links: nil
        ))
    }

    static func textPanel(
        id: Int,
        title: String,
        content: String,
        x: Int,
        y: Int,
        w: Int,
        h: Int
    ) -> GrafanaPanel {
        .text(TextPanel(
            gridPos: GridPos(h: h, w: w, x: x, y: y),
            id: id,
            options: TextPanelOptions(
                code: TextCodeOptions(language: "markdown", showLineNumbers: false),
                content: content
            ),
            title: title
        ))
    }

    /// Wraps overview tiles with drill-through links to the corresponding detail dashboard.
    static func applyDrillthrough(_ panel: GrafanaPanel, dashboardUID: String) -> GrafanaPanel {
        switch panel {
        case .stat(let p):
            return .stat(withDrillthrough(p, dashboardUID: dashboardUID))
        case .timeseries(let p):
            return .timeseries(withDrillthrough(p, dashboardUID: dashboardUID))
        case .table(let p):
            return .table(withDrillthrough(p, dashboardUID: dashboardUID))
        case .barchart(let p):
            return .barchart(withDrillthrough(p, dashboardUID: dashboardUID))
        case .text:
            return panel
        }
    }
}
