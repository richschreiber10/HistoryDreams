import SwiftUI

@main
struct HistoryDreamsApp: App {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var audioManager: AudioManager
    
    init() {
        let settings = SettingsManager()
        _settingsManager = StateObject(wrappedValue: settings)
        _audioManager = StateObject(wrappedValue: AudioManager(settingsManager: settings))
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(audioManager)
                .environmentObject(settingsManager)
                .preferredColorScheme(settingsManager.darkModeEnabled ? .dark : .light)
        }
    }
} 