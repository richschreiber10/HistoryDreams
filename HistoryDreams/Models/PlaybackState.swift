import Foundation

struct PlaybackState: Codable {
    var currentStoryID: UUID?
    var currentTime: TimeInterval
    var isPlaying: Bool
    var sleepTimerEndTime: Date?
    
    static let initial = PlaybackState(
        currentStoryID: nil,
        currentTime: 0,
        isPlaying: false,
        sleepTimerEndTime: nil
    )
}

// MARK: - Persistence
extension PlaybackState {
    private enum Keys {
        static let playbackState = "com.historydreams.playbackstate"
    }
    
    static func load() -> PlaybackState {
        guard let data = UserDefaults.standard.data(forKey: Keys.playbackState),
              let state = try? JSONDecoder().decode(PlaybackState.self, from: data)
        else {
            return .initial
        }
        return state
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Keys.playbackState)
    }
    
    var hasActiveTimer: Bool {
        guard let endTime = sleepTimerEndTime else { return false }
        return endTime > Date()
    }
    
    var remainingTimerDuration: TimeInterval? {
        guard let endTime = sleepTimerEndTime else { return nil }
        return endTime.timeIntervalSince(Date())
    }
} 