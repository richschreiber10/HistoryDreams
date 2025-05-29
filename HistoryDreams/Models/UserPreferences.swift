import Foundation

struct UserPreferences: Codable {
    var isDarkMode: Bool
    var playbackSpeed: Float
    var volume: Float
    var autoplayEnabled: Bool
    var defaultSleepTimer: Int // in minutes
    var rememberPlaybackPosition: Bool
    var offlineModeEnabled: Bool
    var backgroundPlaybackEnabled: Bool
    
    // Audio fade settings
    var fadeOutEnabled: Bool
    var fadeOutDuration: Int // in seconds
    
    static let `default` = UserPreferences(
        isDarkMode: true,
        playbackSpeed: 1.0,
        volume: 1.0,
        autoplayEnabled: false,
        defaultSleepTimer: 30,
        rememberPlaybackPosition: true,
        offlineModeEnabled: false,
        backgroundPlaybackEnabled: true,
        fadeOutEnabled: true,
        fadeOutDuration: 30
    )
}

// MARK: - UserDefaults Storage
extension UserPreferences {
    private enum Keys {
        static let preferences = "com.historydreams.userpreferences"
    }
    
    static func load() -> UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: Keys.preferences),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data)
        else {
            return .default
        }
        return preferences
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Keys.preferences)
    }
} 