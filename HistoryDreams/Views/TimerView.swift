import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager: TimerManager
    
    init(audioManager: AudioManager) {
        _timerManager = StateObject(wrappedValue: TimerManager(audioManager: audioManager))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Sleep Timer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // Circular Timer Display
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: timerManager.isTimerActive ? timerManager.remainingTime / timerManager.selectedDuration : 1)
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: timerManager.remainingTime)
                
                VStack {
                    Image(systemName: "clock")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("\(Int(timerManager.isTimerActive ? timerManager.remainingTime / 60 : timerManager.selectedDuration / 60))")
                        .font(.system(size: 44, weight: .bold))
                    
                    Text("minutes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Duration Selection
            VStack(alignment: .leading, spacing: 16) {
                Text("Select Duration")
                    .font(.title2)
                    .fontWeight(.bold)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(timerManager.availableDurations, id: \.self) { duration in
                        Button(action: {
                            timerManager.setDuration(duration)
                        }) {
                            Text(formatDuration(duration))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(duration == timerManager.selectedDuration ? Color.blue : Color.gray.opacity(0.1))
                                .foregroundColor(duration == timerManager.selectedDuration ? .white : .primary)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Start Timer Button
            Button(action: {
                if timerManager.isTimerActive {
                    timerManager.stopTimer()
                } else {
                    timerManager.startTimer()
                }
            }) {
                Text(timerManager.isTimerActive ? "Stop Timer" : "Start Timer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // When Timer Ends Section
            VStack(alignment: .leading, spacing: 16) {
                Text("When Timer Ends")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    Toggle(isOn: .constant(true)) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)
                            Text("Stop Playing")
                        }
                    }
                    
                    Toggle(isOn: $timerManager.shouldFadeOut) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.blue)
                            Text("Fade Audio Out")
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        if minutes >= 60 {
            let hours = Double(minutes) / 60
            return String(format: "%.1f hours", hours)
        } else {
            return "\(minutes) min"
        }
    }
}

#Preview {
    TimerView(audioManager: AudioManager())
} 