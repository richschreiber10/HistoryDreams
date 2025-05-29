import SwiftUI

struct TestAudioView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Test")
                .font(.title)
            
            // Status
            VStack(spacing: 10) {
                if let story = audioManager.currentStory {
                    Text("Title: \(story.title)")
                    Text("Narrator: \(story.narrator)")
                    Text("Category: \(story.category.rawValue)")
                    Text("Duration: \(story.formattedDuration)")
                    Text("Current Time: \(formatTime(audioManager.playbackState.currentTime))")
                    if let progress = story.progress {
                        Text("Progress: \(Int(progress * 100))%")
                    }
                } else {
                    Text("No audio loaded")
                }
                
                if let error = audioManager.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                }
            }
            .font(.subheadline)
            
            // Controls
            HStack(spacing: 40) {
                Button(action: {
                    audioManager.loadSampleAudio()
                }) {
                    Label("Load", systemImage: "square.and.arrow.down")
                }
                
                Button(action: {
                    audioManager.togglePlayback()
                }) {
                    Label(audioManager.playbackState.isPlaying ? "Pause" : "Play", 
                          systemImage: audioManager.playbackState.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
            }
            
            if audioManager.currentStory != nil {
                PlayerControls()
            }
        }
        .padding()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 