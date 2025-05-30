import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published var volume: Double = 0.8 // 80% default
    @Published var playbackSpeed: Double = 1.0
    @Published var autoplayEnabled: Bool = false
    @Published var darkModeEnabled: Bool = true
    @Published var notificationsEnabled: Bool = true
    @Published var rememberPlaybackPosition: Bool = true
    @Published var backgroundPlaybackEnabled: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let volumeKey = "settings.volume"
    private let playbackSpeedKey = "settings.playbackSpeed"
    private let autoplayKey = "settings.autoplay"
    private let darkModeKey = "settings.darkMode"
    private let notificationsKey = "settings.notifications"
    private let rememberPlaybackKey = "settings.rememberPlayback"
    private let backgroundPlaybackKey = "settings.backgroundPlayback"
    
    init() {
        // Load saved settings
        volume = userDefaults.double(forKey: volumeKey)
        playbackSpeed = userDefaults.double(forKey: playbackSpeedKey)
        autoplayEnabled = userDefaults.bool(forKey: autoplayKey)
        darkModeEnabled = userDefaults.bool(forKey: darkModeKey)
        notificationsEnabled = userDefaults.bool(forKey: notificationsKey)
        rememberPlaybackPosition = userDefaults.bool(forKey: rememberPlaybackKey)
        backgroundPlaybackEnabled = userDefaults.bool(forKey: backgroundPlaybackKey)
        
        // Set defaults if no saved values
        if volume == 0 { volume = 0.8 }
        if playbackSpeed == 0 { playbackSpeed = 1.0 }
        if !userDefaults.contains(key: rememberPlaybackKey) { rememberPlaybackPosition = true }
        if !userDefaults.contains(key: backgroundPlaybackKey) { backgroundPlaybackEnabled = true }
    }
    
    // MARK: - Volume Control
    func setVolume(_ value: Double) {
        volume = value
        userDefaults.set(value, forKey: volumeKey)
    }
    
    // MARK: - Playback Speed
    func setPlaybackSpeed(_ value: Double) {
        playbackSpeed = value
        userDefaults.set(value, forKey: playbackSpeedKey)
    }
    
    // MARK: - Autoplay
    func toggleAutoplay() {
        autoplayEnabled.toggle()
        userDefaults.set(autoplayEnabled, forKey: autoplayKey)
    }
    
    // MARK: - Dark Mode
    func toggleDarkMode() {
        darkModeEnabled.toggle()
        userDefaults.set(darkModeEnabled, forKey: darkModeKey)
    }
    
    // MARK: - Notifications
    func toggleNotifications() {
        notificationsEnabled.toggle()
        userDefaults.set(notificationsEnabled, forKey: notificationsKey)
    }
    
    // MARK: - Playback Position
    func toggleRememberPlaybackPosition() {
        rememberPlaybackPosition.toggle()
        userDefaults.set(rememberPlaybackPosition, forKey: rememberPlaybackKey)
    }
    
    // MARK: - Background Playback
    func toggleBackgroundPlayback() {
        backgroundPlaybackEnabled.toggle()
        userDefaults.set(backgroundPlaybackEnabled, forKey: backgroundPlaybackKey)
    }
    
    // Available playback speeds
    let availablePlaybackSpeeds: [Double] = [0.5, 0.75, 1.0, 1.25, 1.5]
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
} 