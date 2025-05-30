import SwiftUI

struct ManageDownloadsView: View {
    var body: some View {
        VStack {
            Text("Manage Downloads")
                .font(.largeTitle)
                .padding()
            Text("Options for managing downloaded content will appear here.")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .navigationTitle("Manage Downloads")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ManageDownloadsView()
    }
} 