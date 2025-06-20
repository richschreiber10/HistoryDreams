import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var isDownloadOverCellular = false
    @State private var autoPlayNextStory = true
    @State private var selectedVoice = "Default"
    @State private var playbackSpeed = 1.0
    
    let availableVoices = ["Default", "British", "American", "Australian"]
    let speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $settingsManager.darkModeEnabled)
                }
                
                Section("Playback") {
                    Picker("Narrator Voice", selection: $selectedVoice) {
                        ForEach(availableVoices, id: \.self) { voice in
                            Text(voice).tag(voice)
                        }
                    }
                    
                    Picker("Playback Speed", selection: $playbackSpeed) {
                        ForEach(speedOptions, id: \.self) { speed in
                            Text("\(speed)x").tag(speed)
                        }
                    }
                    
                    Toggle("Auto-play Next Story", isOn: $autoPlayNextStory)
                }
                
                Section("Downloads") {
                    Toggle("Download over Cellular", isOn: $isDownloadOverCellular)
                    
                    NavigationLink {
                        ManageDownloadsView()
                    } label: {
                        Text("Manage Downloads")
                    }
                }
                
                Section("About") {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Text("Terms of Service")
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
} 