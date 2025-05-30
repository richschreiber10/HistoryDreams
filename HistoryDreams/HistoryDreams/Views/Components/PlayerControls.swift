import SwiftUI

struct PlayerControls: View {
    @EnvironmentObject var audioManager: AudioManager
    @State private var isShowingTimerPicker = false
    
    private let timerOptions = [10, 15, 30, 45, 60, 90]
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress Bar
            ProgressBar(progress: currentProgress)
                .frame(height: 4)
                .padding(.horizontal)
            
            // Time Labels
            HStack {
                Text(formatTime(audioManager.playbackState.currentTime))
                Spacer()
                Text("-" + formatTime(timeRemaining))
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            
            // Main Controls
            HStack(spacing: 40) {
                Button(action: rewind15) {
                    Image(systemName: "gobackward.15")
                        .font(.title)
                }
                
                Button(action: audioManager.togglePlayback) {
                    Image(systemName: audioManager.playbackState.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                }
                
                Button(action: forward15) {
                    Image(systemName: "goforward.15")
                        .font(.title)
                }
            }
            .foregroundColor(.primary)
            
            // Sleep Timer Button
            Button(action: { isShowingTimerPicker.toggle() }) {
                HStack {
                    Image(systemName: "moon.fill")
                    Text(timerButtonText)
                }
                .foregroundColor(.secondary)
            }
            .sheet(isPresented: $isShowingTimerPicker) {
                TimerPickerSheet(isPresented: $isShowingTimerPicker)
            }
        }
        .padding()
    }
    
    private var currentProgress: Double {
        guard let story = audioManager.currentStory else { return 0 }
        return audioManager.playbackState.currentTime / story.duration
    }
    
    private var timeRemaining: TimeInterval {
        guard let story = audioManager.currentStory else { return 0 }
        return story.duration - audioManager.playbackState.currentTime
    }
    
    private var timerButtonText: String {
        if let remaining = audioManager.playbackState.remainingTimerDuration {
            return "Sleep in \(Int(remaining / 60))m \(Int(remaining.truncatingRemainder(dividingBy: 60)))s"
        }
        return "Sleep Timer"
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func rewind15() {
        let newTime = max(audioManager.playbackState.currentTime - 15, 0)
        audioManager.seek(to: newTime / (audioManager.currentStory?.duration ?? 1))
    }
    
    private func forward15() {
        guard let duration = audioManager.currentStory?.duration else { return }
        let newTime = min(audioManager.playbackState.currentTime + 15, duration)
        audioManager.seek(to: newTime / duration)
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.secondary.opacity(0.2))
                
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: geometry.size.width * CGFloat(progress))
            }
            .cornerRadius(2)
        }
    }
}

// MARK: - Timer Picker Sheet
struct TimerPickerSheet: View {
    @EnvironmentObject var audioManager: AudioManager
    @Binding var isPresented: Bool
    
    private let timerOptions = [10, 15, 30, 45, 60, 90]
    
    var body: some View {
        NavigationView {
            List {
                Button("Cancel Timer") {
                    audioManager.cancelSleepTimer()
                    isPresented = false
                }
                .foregroundColor(.red)
                
                ForEach(timerOptions, id: \.self) { minutes in
                    Button(action: {
                        audioManager.startSleepTimer(duration: TimeInterval(minutes * 60))
                        isPresented = false
                    }) {
                        Text("\(minutes) minutes")
                    }
                }
            }
            .navigationTitle("Sleep Timer")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
} 