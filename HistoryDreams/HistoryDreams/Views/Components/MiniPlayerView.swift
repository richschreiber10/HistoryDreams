import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        if let story = audioManager.currentStory {
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 16) {
                    // Story Image
                    if let thumbnailURL = story.thumbnailURL {
                        AsyncImage(url: thumbnailURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        } placeholder: {
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading)
                    } else {
                        Image(systemName: "book.closed.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .padding(.leading)
                    }
                    
                    // Title and Progress
                    VStack(alignment: .leading, spacing: 2) {
                        Text(story.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 2)
                                    .opacity(0.3)
                                    .foregroundColor(.gray)
                                
                                Rectangle()
                                    .frame(width: geometry.size.width * CGFloat(audioManager.playbackState.currentTime / story.duration), height: 2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(height: 2)
                        
                        // Time
                        HStack {
                            Text(formatTime(audioManager.playbackState.currentTime))
                            Text("/")
                            Text(formatTime(story.duration))
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: 20) {
                        Button(action: {
                            audioManager.seek(to: max(audioManager.playbackState.currentTime - 15, 0) / story.duration)
                        }) {
                            Image(systemName: "gobackward.15")
                                .font(.title2)
                        }
                        
                        Button(action: audioManager.togglePlayback) {
                            Image(systemName: audioManager.playbackState.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title)
                        }
                        
                        Button(action: {
                            audioManager.seek(to: min(audioManager.playbackState.currentTime + 15, story.duration) / story.duration)
                        }) {
                            Image(systemName: "goforward.15")
                                .font(.title2)
                        }
                    }
                    .padding(.trailing)
                }
                .frame(height: 60)
            }
        }
    }
    
    private func formatTime(_ timeInSeconds: TimeInterval) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    MiniPlayerView()
        .environmentObject(AudioManager())
} 