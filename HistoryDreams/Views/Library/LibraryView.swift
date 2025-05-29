import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""
    @State private var selectedFilter: LibraryFilter = .all
    
    var body: some View {
        NavigationStack {
            VStack {
                // Filter picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(LibraryFilter.allCases) { filter in
                        Text(filter.title)
                            .tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Library content
                List {
                    ForEach(1...10, id: \.self) { _ in
                        NavigationLink {
                            Text("Story Details")
                        } label: {
                            StoryRowView(title: "Historical Story",
                                       author: "Historian",
                                       duration: "1 hr",
                                       progress: 0.0)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search stories")
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}

enum LibraryFilter: String, CaseIterable, Identifiable {
    case all
    case downloaded
    case favorites
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .downloaded: return "Downloaded"
        case .favorites: return "Favorites"
        }
    }
}

#Preview {
    LibraryView()
} 