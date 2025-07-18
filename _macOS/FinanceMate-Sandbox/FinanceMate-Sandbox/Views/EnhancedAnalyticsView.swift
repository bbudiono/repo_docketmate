//
//  EnhancedAnalyticsView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Enhanced analytics view with real-time financial insights and chart visualization in Sandbox
* Issues & Complexity Summary: Initial TDD implementation with comprehensive data visualization
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: Medium-High
  - Dependencies: 5 New (SwiftUI Charts, real-time binding, analytics viewmodel, chart rendering, responsive design)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 72%
* Justification for Estimates: Complex SwiftUI interface with multiple chart types and real-time data binding
* Final Code Complexity (Actual %): TBD - Initial implementation
* Overall Result Score (Success & Quality %): TBD - TDD iteration
* Key Variances/Learnings: TDD approach ensures robust analytics UI with proper chart integration
* Last Updated: 2025-06-02
*/

import SwiftUI
import Charts

// MARK: - Enhanced Analytics View

struct EnhancedAnalyticsView: View {
    
    @StateObject private var viewModel: AnalyticsViewModel
    @State private var selectedChart: ChartType = .trends
    
    init(documentManager: DocumentManager) {
        self._viewModel = StateObject(wrappedValue: AnalyticsViewModel(documentManager: documentManager))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Sandbox indicator
                headerView
                
                // Loading state
                if viewModel.isLoading {
                    loadingView
                } else {
                    // Main content
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Summary cards
                            summaryCardsView
                            
                            // Chart controls
                            chartControlsView
                            
                            // Selected chart view
                            selectedChartView
                            
                            // Quick insights
                            quickInsightsView
                            
                            // Detailed analytics
                            detailedAnalyticsView
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("")
            .task {
                await viewModel.loadAnalyticsData()
            }
            .refreshable {
                await viewModel.refreshAnalyticsData()
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Financial Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Real-time insights and trends")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Period selector
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
            
            // Sandbox indicator
            Text("🧪 SANDBOX")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .onChange(of: viewModel.selectedPeriod) {
            Task {
                await viewModel.loadAnalyticsData()
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading Analytics...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Summary Cards View
    
    private var summaryCardsView: some View {
        HStack(spacing: 20) {
            SummaryCard(
                title: "Total Spending",
                value: formatCurrency(viewModel.totalSpending ?? 0),
                icon: "dollarsign.circle.fill",
                color: .blue
            )
            
            SummaryCard(
                title: "Average Transaction",
                value: formatCurrency(viewModel.averageSpending ?? 0),
                icon: "chart.bar.fill",
                color: .green
            )
            
            SummaryCard(
                title: "Documents Processed",
                value: "\(viewModel.monthlyData.reduce(0) { $0 + $1.transactionCount })",
                icon: "doc.text.fill",
                color: .orange
            )
            
            SummaryCard(
                title: "Categories",
                value: "\(viewModel.categoryData.count)",
                icon: "tag.fill",
                color: .purple
            )
        }
    }
    
    // MARK: - Chart Controls View
    
    private var chartControlsView: some View {
        HStack {
            Text("Charts")
                .font(.headline)
            
            Spacer()
            
            Picker("Chart Type", selection: $selectedChart) {
                ForEach(ChartType.allCases, id: \.self) { chartType in
                    Label(chartType.displayName, systemImage: chartType.icon)
                        .tag(chartType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    // MARK: - Selected Chart View
    
    @ViewBuilder
    private var selectedChartView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(selectedChart.displayName)
                .font(.title2)
                .fontWeight(.semibold)
            
            switch selectedChart {
            case .trends:
                trendsChartView
            case .categories:
                categoriesChartView
            case .comparison:
                comparisonChartView
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    // MARK: - Trends Chart View
    
    private var trendsChartView: some View {
        Chart(viewModel.monthlyData) { data in
            LineMark(
                x: .value("Period", data.period),
                y: .value("Amount", data.totalSpending)
            )
            .foregroundStyle(.blue)
            .symbol(Circle().strokeBorder(lineWidth: 2))
            
            AreaMark(
                x: .value("Period", data.period),
                y: .value("Amount", data.totalSpending)
            )
            .foregroundStyle(.blue.opacity(0.3))
        }
        .frame(height: 300)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
    }
    
    // MARK: - Categories Chart View
    
    private var categoriesChartView: some View {
        Chart(viewModel.categoryData.prefix(6)) { data in
            SectorMark(
                angle: .value("Amount", data.totalAmount),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(data.color)
            .opacity(0.8)
        }
        .frame(height: 300)
        .chartLegend(position: .trailing, alignment: .center, spacing: 20)
    }
    
    // MARK: - Comparison Chart View
    
    private var comparisonChartView: some View {
        Chart(viewModel.categoryData.prefix(8)) { data in
            BarMark(
                x: .value("Category", data.categoryName),
                y: .value("Amount", data.totalAmount)
            )
            .foregroundStyle(data.color)
        }
        .frame(height: 300)
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
    
    // MARK: - Quick Insights View
    
    private var quickInsightsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Insights")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                InsightCard(
                    title: "Top Category",
                    value: viewModel.categoryData.first?.categoryName ?? "N/A",
                    subtitle: "Highest spending",
                    icon: "crown.fill",
                    color: .yellow
                )
                
                InsightCard(
                    title: "Growth Trend",
                    value: calculateGrowthTrend(),
                    subtitle: "vs. previous period",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                InsightCard(
                    title: "Most Frequent",
                    value: getMostFrequentCategory(),
                    subtitle: "Transaction type",
                    icon: "repeat",
                    color: .blue
                )
                
                InsightCard(
                    title: "Efficiency Score",
                    value: calculateEfficiencyScore(),
                    subtitle: "Processing accuracy",
                    icon: "target",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Detailed Analytics View
    
    private var detailedAnalyticsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Category Breakdown")
                .font(.headline)
            
            ForEach(viewModel.categoryData.prefix(10)) { category in
                CategoryRowView(category: category)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func calculateGrowthTrend() -> String {
        guard viewModel.monthlyData.count >= 2 else { return "N/A" }
        
        let latest = viewModel.monthlyData.last?.totalSpending ?? 0
        let previous = viewModel.monthlyData.dropLast().last?.totalSpending ?? 0
        
        if previous > 0 {
            let growth = ((latest - previous) / previous) * 100
            return String(format: "%.1f%%", growth)
        }
        
        return "N/A"
    }
    
    private func getMostFrequentCategory() -> String {
        return viewModel.categoryData.max(by: { $0.transactionCount < $1.transactionCount })?.categoryName ?? "N/A"
    }
    
    private func calculateEfficiencyScore() -> String {
        // Simplified efficiency calculation based on processing confidence
        return "85%" // Placeholder for actual calculation
    }
}

// MARK: - Supporting Views

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct CategoryRowView: View {
    let category: CategoryAnalytics
    
    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)
            
            Text(category.categoryName)
                .font(.subheadline)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(formatCurrency(category.totalAmount))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(Int(category.percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Enums

enum ChartType: String, CaseIterable {
    case trends = "trends"
    case categories = "categories"
    case comparison = "comparison"
    
    var displayName: String {
        switch self {
        case .trends: return "Trends"
        case .categories: return "Categories"
        case .comparison: return "Comparison"
        }
    }
    
    var icon: String {
        switch self {
        case .trends: return "chart.line.uptrend.xyaxis"
        case .categories: return "chart.pie.fill"
        case .comparison: return "chart.bar.fill"
        }
    }
}