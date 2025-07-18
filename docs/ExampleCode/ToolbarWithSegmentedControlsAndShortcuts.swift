import SwiftUI

/// # Toolbar with Segmented Controls and Shortcuts (Conceptual)
/// Demonstrates a custom toolbar with:
/// - Segmented controls for mode switching
/// - Overflow menu for extra actions
/// - Quick-access keyboard shortcut bar
struct ToolbarWithSegmentedControlsAndShortcuts: View {
    @State private var selectedMode: Mode = .edit
    @State private var showOverflowMenu = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 16) {
                // Segmented Control
                Picker("Mode", selection: $selectedMode) {
                    ForEach(Mode.allCases, id: \. self) { mode in
                        Label(mode.rawValue, systemImage: mode.icon)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 320)
                
                // Overflow Menu
                Menu {
                    Button("Export", systemImage: "square.and.arrow.up") {}
                    Button("Import", systemImage: "square.and.arrow.down") {}
                    Divider()
                    Button("Settings", systemImage: "gear") {}
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .padding(.horizontal, 8)
                }
                .menuStyle(.borderlessButton)
                
                Spacer()
                
                // Quick-Access Shortcuts
                ShortcutBar(for: selectedMode)
            }
            .padding(.horizontal)
            .frame(height: 48)
            .background(.ultraThinMaterial)
            .shadow(radius: 2)
            
            Divider()
            
            // Main Content
            ZStack {
                Rectangle().fill(Color.white)
                Text("Current Mode: \(selectedMode.rawValue)")
                    .font(.largeTitle)
            }
        }
    }
}

// MARK: - Mode Enum
enum Mode: String, CaseIterable {
    case edit = "Edit"
    case view = "View"
    case annotate = "Annotate"
    case preview = "Preview"
    
    var icon: String {
        switch self {
        case .edit: return "pencil"
        case .view: return "eye"
        case .annotate: return "highlighter"
        case .preview: return "doc.text.magnifyingglass"
        }
    }
}

// MARK: - Shortcut Bar
struct ShortcutBar: View {
    let mode: Mode
    
    var shortcuts: [Shortcut] {
        switch mode {
        case .edit:
            return [
                Shortcut(key: "⌘S", action: "Save"),
                Shortcut(key: "⌘Z", action: "Undo"),
                Shortcut(key: "⌘Y", action: "Redo")
            ]
        case .view:
            return [
                Shortcut(key: "⌘F", action: "Find"),
                Shortcut(key: "⌘+", action: "Zoom In"),
                Shortcut(key: "⌘-", action: "Zoom Out")
            ]
        case .annotate:
            return [
                Shortcut(key: "⌘B", action: "Bold"),
                Shortcut(key: "⌘I", action: "Italic"),
                Shortcut(key: "⌘U", action: "Underline")
            ]
        case .preview:
            return [
                Shortcut(key: "Esc", action: "Exit Preview")
            ]
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(shortcuts) { shortcut in
                HStack(spacing: 4) {
                    Text(shortcut.key)
                        .font(.system(.body, design: .monospaced))
                        .padding(4)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(4)
                    Text(shortcut.action)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct Shortcut: Identifiable {
    let id = UUID()
    let key: String
    let action: String
}

// MARK: - Preview
#Preview {
    ToolbarWithSegmentedControlsAndShortcuts()
        .frame(width: 900, height: 400)
} 