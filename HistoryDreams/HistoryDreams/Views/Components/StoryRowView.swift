import SwiftUI

struct StoryRowView: View {
    let title: String
    let author: String
    let duration: String
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack {
                Text(author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(duration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if progress > 0 {
                ProgressView(value: progress)
                    .tint(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StoryRowView(
        title: "Sample Story",
        author: "Author Name",
        duration: "45 min",
        progress: 0.3
    )
    .padding()
} 