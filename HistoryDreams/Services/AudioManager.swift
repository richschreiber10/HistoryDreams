import Foundation
import AVFoundation
import Combine

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
    
    // MARK: - Initialization
    init(userPreferences: UserPreferences = .load()) {
        self.userPreferences = userPreferences
        self.playbackState = .initial
        setupAudioSession()
    }
    
    deinit {
        removeTimeObserver()
        sleepTimer?.invalidate()
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
                            progress: 0
                        )
                    }
                }
            }
            .store(in: &cancellables)
        
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
    
    // MARK: - Private Methods
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            self.error = error
        }
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.playbackState = PlaybackState(
                currentStoryID: self.currentStory?.id,
                currentTime: time.seconds,
                isPlaying: self.playbackState.isPlaying,
                sleepTimerEndTime: self.playbackState.sleepTimerEndTime
            )
        }
    }
    
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
} 