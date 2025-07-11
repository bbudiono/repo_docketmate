import SwiftUI

/// # Multi-Panel Workspace with Mini-Map (Conceptual)
/// Demonstrates a complex workspace with:
/// - HSplitView/VSplitView for multi-panel layout
/// - Collapsible inspector panel
/// - Floating mini-map overlay
/// - Animated transitions between panels
struct MultiPanelWorkspaceWithMiniMap: View {
    @State private var showInspector = true
    @State private var showMiniMap = false
    @State private var selectedPanel: String? = "Main"
    
    var body: some View {
        HSplitView {
            // Sidebar
            VStack {
                Text("Sidebar")
                    .font(.headline)
                List(["Project 1", "Project 2", "Project 3"], id: \. self) { item in
                    Button(item) { selectedPanel = item }
                }
                Spacer()
            }
            .frame(minWidth: 180, maxWidth: 220)
            .background(Color.gray.opacity(0.08))
            
            // Main Content + Inspector
            VSplitView {
                ZStack(alignment: .topTrailing) {
                    // Main Content
                    ZStack {
                        Rectangle().fill(Color.white)
                        Text(selectedPanel ?? "Main")
                            .font(.largeTitle)
                    }
                    .animation(.easeInOut, value: selectedPanel)
                    
                    // Mini-Map Overlay
                    if showMiniMap {
                        MiniMapView()
                            .frame(width: 180, height: 120)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                            .padding()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(showMiniMap ? "Hide Mini-Map" : "Show Mini-Map") {
                            withAnimation { showMiniMap.toggle() }
                        }
                    }
                }
                
                // Inspector Panel
                if showInspector {
                    InspectorPanelView()
                        .frame(minHeight: 180, maxHeight: 300)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(showInspector ? "Hide Inspector" : "Show Inspector") {
                    withAnimation { showInspector.toggle() }
                }
            }
        }
    }
}

// MARK: - Mini-Map View
struct MiniMapView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Mini-Map")
                .font(.headline)
            Rectangle()
                .fill(Color.blue.opacity(0.2))
                .frame(height: 60)
                .overlay(Text("Overview").font(.caption))
            Spacer()
        }
        .padding(8)
    }
}

// MARK: - Inspector Panel
struct InspectorPanelView: View {
    @State private var property1: String = ""
    @State private var property2: Double = 0.5
    var body: some View {
        Form {
            Section(header: Text("Inspector")) {
                TextField("Property 1", text: $property1)
                Slider(value: $property2, in: 0...1) {
                    Text("Property 2")
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MultiPanelWorkspaceWithMiniMap()
        .frame(width: 1000, height: 600)
} 