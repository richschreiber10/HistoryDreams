import SwiftUI

struct TimerView: View {
    @State private var selectedDuration: TimeInterval = 30 * 60 // 30 minutes default
    @State private var isTimerRunning = false
    @State private var remainingTime: TimeInterval = 0
    
    let availableDurations: [TimeInterval] = [
        15 * 60,  // 15 minutes
        30 * 60,  // 30 minutes
        45 * 60,  // 45 minutes
        60 * 60,  // 1 hour
        90 * 60   // 1.5 hours
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Timer display
                VStack {
                    Text(formatTime(remainingTime > 0 ? remainingTime : selectedDuration))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    Text(isTimerRunning ? "Time Remaining" : "Selected Duration")
                        .foregroundStyle(.secondary)
                }
                
                // Duration picker (when timer is not running)
                if !isTimerRunning {
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(availableDurations, id: \.self) { duration in
                            Text(formatTime(duration))
                                .tag(duration)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                // Start/Stop button
                Button(action: toggleTimer) {
                    Text(isTimerRunning ? "Cancel Timer" : "Start Timer")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isTimerRunning ? .red : .blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Sleep Timer")
        }
    }
    
    private func toggleTimer() {
        isTimerRunning.toggle()
        if isTimerRunning {
            remainingTime = selectedDuration
            // Timer functionality to be implemented
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:00", hours, minutes)
        } else {
            return String(format: "%d:00", minutes)
        }
    }
}

#Preview {
    TimerView()
} 