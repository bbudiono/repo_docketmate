import SwiftUI

/// # Floating Action Button with Contextual Menu (Conceptual)
/// Demonstrates a FAB that expands to show contextual actions, with animated transitions and popovers.
struct FloatingActionButtonWithContextMenu: View {
    @State private var expanded = false
    @State private var selectedAction: FABAction? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main Content
            Rectangle().fill(Color(.systemBackground))
                .ignoresSafeArea()
            
            // FAB and Actions
            VStack(alignment: .trailing, spacing: 16) {
                if expanded {
                    ForEach(FABAction.allCases, id: \. self) { action in
                        Button {
                            selectedAction = action
                        } label: {
                            Label(action.label, systemImage: action.icon)
                                .padding(10)
                                .background(Circle().fill(action.color))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                        }
                        .popover(isPresented: Binding(
                            get: { selectedAction == action },
                            set: { if !$0 { selectedAction = nil } }
                        )) {
                            VStack(spacing: 12) {
                                Text(action.label)
                                    .font(.headline)
                                Text(action.description)
                                    .font(.body)
                                Button("Close") { selectedAction = nil }
                            }
                            .padding()
                            .frame(width: 220)
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                // FAB
                Button {
                    withAnimation(.spring()) { expanded.toggle() }
                } label: {
                    Image(systemName: expanded ? "xmark" : "plus")
                        .font(.system(size: 28, weight: .bold))
                        .padding(20)
                        .background(Circle().fill(Color.accentColor))
                        .foregroundColor(.white)
                        .shadow(radius: 8)
                }
                .accessibilityLabel(expanded ? "Close actions" : "Open actions")
            }
            .padding(32)
        }
    }
}

// MARK: - FAB Actions
enum FABAction: CaseIterable, Equatable {
    case add, scan, importData, exportData
    
    var label: String {
        switch self {
        case .add: return "Add"
        case .scan: return "Scan"
        case .importData: return "Import"
        case .exportData: return "Export"
        }
    }
    var icon: String {
        switch self {
        case .add: return "plus"
        case .scan: return "qrcode.viewfinder"
        case .importData: return "square.and.arrow.down"
        case .exportData: return "square.and.arrow.up"
        }
    }
    var color: Color {
        switch self {
        case .add: return .green
        case .scan: return .blue
        case .importData: return .orange
        case .exportData: return .purple
        }
    }
    var description: String {
        switch self {
        case .add: return "Create a new item or entry."
        case .scan: return "Scan a QR code or barcode."
        case .importData: return "Import data from a file or source."
        case .exportData: return "Export your data to a file or service."
        }
    }
}

// MARK: - Preview
#Preview {
    FloatingActionButtonWithContextMenu()
        .frame(width: 800, height: 600)
} 