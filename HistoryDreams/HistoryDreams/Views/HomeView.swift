import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Continue Listening") {
                    ForEach(1...3, id: \.self) { _ in
                        NavigationLink {
                            Text("Story Details")
                        } label: {
                            StoryRowView(title: "Sample Story", 
                                       author: "Author Name",
                                       duration: "45 min",
                                       progress: 0.3)
                        }
                    }
                }
                
                Section("Recently Added") {
                    ForEach(1...5, id: \.self) { _ in
                        NavigationLink {
                            Text("Story Details")
                        } label: {
                            StoryRowView(title: "New Story", 
                                       author: "Another Author",
                                       duration: "30 min",
                                       progress: 0.0)
                        }
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
} 