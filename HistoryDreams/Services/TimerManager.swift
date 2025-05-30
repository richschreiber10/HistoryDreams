import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var selectedDuration: TimeInterval = 30 * 60 // Default 30 minutes
    @Published var remainingTime: TimeInterval = 0
    @Published var isTimerActive = false
    @Published var shouldFadeOut = false
    
    private var timer: Timer?
    private var audioManager: AudioManager
    
    // Available durations in seconds
    let availableDurations: [TimeInterval] = [
        5 * 60,    // 5 minutes
        15 * 60,   // 15 minutes
        30 * 60,   // 30 minutes
        45 * 60,   // 45 minutes
        60 * 60,   // 1 hour
        90 * 60    // 1.5 hours
    ]
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
    }
    
    func startTimer() {
        stopTimer() // Clear any existing timer
        remainingTime = selectedDuration
        isTimerActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.timerCompleted()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
    }
    
    private func timerCompleted() {
        stopTimer()
        
        if shouldFadeOut {
            audioManager.fadeOutAndStop()
        } else {
            audioManager.pause() // Changed from stop() to pause() to match Services/AudioManager API
        }
    }
    
    func setDuration(_ duration: TimeInterval) {
        selectedDuration = duration
        if isTimerActive {
            startTimer() // Restart timer with new duration
        }
    }
    
    // Format time for display (e.g., "30:00")
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    deinit {
        stopTimer()
    }
} 