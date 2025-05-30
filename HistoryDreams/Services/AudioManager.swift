import Foundation
import AVFoundation
import Combine
import UIKit

class AudioManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var playbackState: PlaybackState
    @Published private(set) var currentStory: Story?
    @Published private(set) var isBuffering = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var sleepTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let userPreferences: UserPreferences
    private var wasPlayingBeforeInterruption = false
    private var progressUpdateThrottle: TimeInterval = 1.0 // Update progress every second
    private var lastProgressUpdate: TimeInterval = 0
    
    // MARK: - Initialization
    init(userPreferences: UserPreferences = .load()) {
        self.userPreferences = userPreferences
        self.playbackState = .initial
        setupAudioSession()
        setupNotifications()
    }
    
    deinit {
        removeTimeObserver()
        sleepTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: - Public Methods
    func loadAudio(from url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Create a test story with initial duration of 0
        currentStory = Story(
            title: "Test Audio",
            description: "A sample audio file for testing",
            narrator: "Test Narrator",
            duration: 0,  // Start with 0 duration
            category: .modernHistory,
            timePeriod: "2024",
            region: "Test Region",
            audioURL: url
        )
        
        // Wait for the item to become ready before accessing duration
        playerItem.publisher(for: \.status)
            .filter { $0 == .readyToPlay }
            .sink { [weak self] _ in
                guard let self = self else { return }
                let duration = CMTimeGetSeconds(playerItem.duration)
                if duration.isFinite && !duration.isNaN {
                    // Update the story with the correct duration
                    if let story = self.currentStory {
                        // Load saved progress if available and user preferences allow
                        let savedProgress = self.loadSavedProgress(for: story.id)
                        let startPosition = self.userPreferences.rememberPlaybackPosition ? savedProgress : 0
                        
                        self.currentStory = Story(
                            id: story.id,
                            title: story.title,
                            description: story.description,
                            narrator: story.narrator,
                            duration: duration,
                            category: story.category,
                            timePeriod: story.timePeriod,
                            region: story.region,
                            thumbnailURL: story.thumbnailURL,
                            audioURL: story.audioURL,
                            lastPlayedDate: Date(),
                            progress: startPosition
                        )
                        
                        // Seek to saved position if needed
                        if startPosition > 0 {
                            self.seek(to: startPosition)
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        // Add completion handler
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlaybackCompletion),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        addTimeObserver()
    }
    
    func loadSampleAudio() {
        // First try looking in the Samples directory
        if let sampleURL = Bundle.main.url(forResource: "sample_history", withExtension: "mp3", subdirectory: "Samples") {
            loadAudio(from: sampleURL)
            return
        }
        
        // If not found in Samples subdirectory, try root level
        if let sampleURL = Bundle.main.url(forResource: "sample_history", withExtension: "mp3") {
            loadAudio(from: sampleURL)
            return
        }
        
        // If still not found, try looking in the app's main bundle directory
        let bundleURL = Bundle.main.bundleURL.appendingPathComponent("sample_history.mp3")
        if FileManager.default.fileExists(atPath: bundleURL.path) {
            loadAudio(from: bundleURL)
            return
        }
        
        // If all attempts fail, report the error
        error = NSError(domain: "AudioManager", 
                       code: -1, 
                       userInfo: [NSLocalizedDescriptionKey: "Could not find sample audio file. Please ensure it's properly added to the app bundle."])
    }
    
    func play() {
        player?.play()
        playbackState = PlaybackState(
            currentStoryID: currentStory?.id,
            currentTime: playbackState.currentTime,
            isPlaying: true,
            sleepTimerEndTime: playbackState.sleepTimerEndTime
        )
    }
    
    func pause() {
        player?.pause()
        playbackState = PlaybackState(
            currentStoryID: currentStory?.id,
            currentTime: playbackState.currentTime,
            isPlaying: false,
            sleepTimerEndTime: playbackState.sleepTimerEndTime
        )
    }
    
    func togglePlayback() {
        if playbackState.isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to progress: Double) {
        guard let duration = currentStory?.duration else { return }
        let targetTime = duration * progress
        
        if let player = player {
            player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
            playbackState = PlaybackState(
                currentStoryID: currentStory?.id,
                currentTime: targetTime,
                isPlaying: playbackState.isPlaying,
                sleepTimerEndTime: playbackState.sleepTimerEndTime
            )
        }
    }
    
    // MARK: - Sleep Timer
    func startSleepTimer(duration: TimeInterval) {
        cancelSleepTimer()
        let endTime = Date().addingTimeInterval(duration)
        playbackState = PlaybackState(
            currentStoryID: currentStory?.id,
            currentTime: playbackState.currentTime,
            isPlaying: playbackState.isPlaying,
            sleepTimerEndTime: endTime
        )
        
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if !self.playbackState.hasActiveTimer {
                self.pause()
                self.cancelSleepTimer()
            }
        }
    }
    
    func fadeOutAndStop(duration: TimeInterval = 5.0) {
        guard let player = player else { return }
        
        // Store initial volume
        let initialVolume = player.volume
        let fadeSteps = 50
        let stepDuration = duration / TimeInterval(fadeSteps)
        let volumeDecrement = initialVolume / Float(fadeSteps)
        
        func fadeStep(stepsRemaining: Int) {
            guard stepsRemaining > 0 else {
                self.pause()
                player.volume = initialVolume // Reset volume
                return
            }
            
            player.volume -= volumeDecrement
            
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
                fadeStep(stepsRemaining: stepsRemaining - 1)
            }
        }
        
        fadeStep(stepsRemaining: fadeSteps)
    }
    
    func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        playbackState = PlaybackState(
            currentStoryID: currentStory?.id,
            currentTime: playbackState.currentTime,
            isPlaying: playbackState.isPlaying,
            sleepTimerEndTime: nil
        )
    }
    
    // MARK: - Audio Session Management
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = error
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupNotifications() {
        // Audio Session Interruption Notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        // Audio Route Change Notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
        // Application Will Enter Background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnterBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        // Application Will Enter Foreground
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            wasPlayingBeforeInterruption = playbackState.isPlaying
            pause()
            
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            if options.contains(.shouldResume) && wasPlayingBeforeInterruption {
                play()
            }
            
        @unknown default:
            break
        }
    }
    
    @objc private func handleAudioRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            // Headphones were unplugged, pause playback
            pause()
        case .newDeviceAvailable, .categoryChange:
            // New audio route is available, ensure session is active
            try? AVAudioSession.sharedInstance().setActive(true)
        default:
            break
        }
    }
    
    @objc private func handleEnterBackground() {
        // Ensure background playback continues if enabled
        if userPreferences.backgroundPlaybackEnabled {
            try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } else {
            pause()
        }
    }
    
    @objc private func handleEnterForeground() {
        // Reactivate audio session when app comes to foreground
        setupAudioSession()
    }
    
    // MARK: - Private Methods
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let story = self.currentStory,
                  let duration = self.player?.currentItem?.duration else { return }
            
            let currentTime = time.seconds
            let totalDuration = CMTimeGetSeconds(duration)
            
            // Calculate progress
            let progress = currentTime / totalDuration
            
            // Update playback state
            self.playbackState = PlaybackState(
                currentStoryID: story.id,
                currentTime: currentTime,
                isPlaying: self.playbackState.isPlaying,
                sleepTimerEndTime: self.playbackState.sleepTimerEndTime
            )
            
            // Throttle progress updates to storage
            if currentTime - self.lastProgressUpdate >= self.progressUpdateThrottle {
                self.lastProgressUpdate = currentTime
                
                // Update story progress
                self.currentStory = Story(
                    id: story.id,
                    title: story.title,
                    description: story.description,
                    narrator: story.narrator,
                    duration: totalDuration,
                    category: story.category,
                    timePeriod: story.timePeriod,
                    region: story.region,
                    thumbnailURL: story.thumbnailURL,
                    audioURL: story.audioURL,
                    lastPlayedDate: Date(),
                    progress: progress
                )
                
                // Save progress if enabled
                if self.userPreferences.rememberPlaybackPosition {
                    self.saveProgress(progress, for: story.id)
                }
            }
        }
    }
    
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    // MARK: - Progress Tracking
    private func loadSavedProgress(for storyId: UUID) -> Double {
        // Load progress from UserDefaults
        let key = "story_progress_\(storyId.uuidString)"
        return UserDefaults.standard.double(forKey: key)
    }
    
    private func saveProgress(_ progress: Double, for storyId: UUID) {
        // Save progress to UserDefaults
        let key = "story_progress_\(storyId.uuidString)"
        UserDefaults.standard.set(progress, forKey: key)
    }
    
    @objc private func handlePlaybackCompletion() {
        // Reset progress and update story
        if let story = currentStory {
            currentStory = Story(
                id: story.id,
                title: story.title,
                description: story.description,
                narrator: story.narrator,
                duration: story.duration,
                category: story.category,
                timePeriod: story.timePeriod,
                region: story.region,
                thumbnailURL: story.thumbnailURL,
                audioURL: story.audioURL,
                lastPlayedDate: Date(),
                progress: 1.0  // Mark as completed
            )
            
            // Save completion state
            saveProgress(1.0, for: story.id)
        }
        
        // Update playback state
        playbackState = PlaybackState(
            currentStoryID: currentStory?.id,
            currentTime: currentStory?.duration ?? 0,
            isPlaying: false,
            sleepTimerEndTime: nil
        )
        
        // Handle autoplay if enabled
        if userPreferences.autoplayEnabled {
            // TODO: Implement autoplay functionality
        }
    }
} 