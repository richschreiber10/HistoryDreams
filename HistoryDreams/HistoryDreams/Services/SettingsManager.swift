import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published private(set) var preferences: UserPreferences {
        didSet {
            preferences.save()
        }
    }
    
    init() {
        self.preferences = .load()
    }
    
    // MARK: - Display Settings
    func toggleDarkMode() {
        preferences.isDarkMode.toggle()
    }
    
    // MARK: - Playback Settings
    func updatePlaybackSpeed(_ speed: Float) {
        preferences.playbackSpeed = min(max(speed, 0.5), 2.0)
    }
    
    func updateVolume(_ volume: Float) {
        preferences.volume = min(max(volume, 0.0), 1.0)
    }
    
    func toggleAutoplay() {
        preferences.autoplayEnabled.toggle()
    }
    
    func updateDefaultSleepTimer(_ minutes: Int) {
        preferences.defaultSleepTimer = max(minutes, 1)
    }
    
    func togglePlaybackPositionMemory() {
        preferences.rememberPlaybackPosition.toggle()
    }
    
    // MARK: - Audio Fade Settings
    func toggleFadeOut() {
        preferences.fadeOutEnabled.toggle()
    }
    
    func updateFadeOutDuration(_ seconds: Int) {
        preferences.fadeOutDuration = max(seconds, 5)
    }
    
    // MARK: - Offline Mode Settings
    func toggleOfflineMode() {
        preferences.offlineModeEnabled.toggle()
    }
    
    func toggleBackgroundPlayback() {
        preferences.backgroundPlaybackEnabled.toggle()
    }
    
    // MARK: - Reset Settings
    func resetToDefaults() {
        preferences = .default
    }
} 