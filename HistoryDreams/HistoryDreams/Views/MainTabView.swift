import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var audioManager: AudioManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical")
                    }
                    .tag(1)
                
                TimerView(audioManager: audioManager)
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
                
                TestAudioView(audioManager: audioManager)
                    .tabItem {
                        Label("Test Audio", systemImage: "speaker.wave.2")
                    }
                    .tag(4)
            }
            
            if audioManager.currentStory != nil {
                VStack {
                    Spacer()
                    MiniPlayerView()
                        .frame(height: 60)
                        .background(Color(UIColor.systemBackground))
                        .offset(y: -49) // Standard tab bar height
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
} 