import SwiftUI

@main
struct HistoryDreamsApp: App {
    @StateObject private var audioManager = AudioManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(audioManager)
        }
    }
} 