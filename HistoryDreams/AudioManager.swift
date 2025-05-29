import Foundation
import AVFoundation

struct Story {
    let title: String
    let author: String
    let duration: TimeInterval
    let audioURL: URL
}

struct PlaybackState: Codable {
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var remainingTimerDuration: TimeInterval?
    
    static func load() -> PlaybackState {
        if let data = UserDefaults.standard.data(forKey: "PlaybackState"),
           let state = try? JSONDecoder().decode(PlaybackState.self, from: data) {
            return state
        }
        return PlaybackState()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "PlaybackState")
        }
    }
}

class AudioManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var playbackState: PlaybackState
    @Published private(set) var currentStory: Story?
    @Published private(set) var isBuffering = false
    
    // MARK: - Private Properties
    private var audioPlayer: AVPlayer?
    private var timeObserver: Any?
    private var sleepTimer: Timer?
    private let userPreferences: UserPreferences
    
    // MARK: - Initialization
    init(userPreferences: UserPreferences = .load()) {
        self.userPreferences = userPreferences
        self.playbackState = .load()
        setupAudioSession()
        
        // Example story for testing
        currentStory = Story(
            title: "Sample Story",
            author: "Author Name",
            duration: 1800, // 30 minutes
            audioURL: URL(string: "https://example.com/audio.mp3")!
        )
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Playback Control
    func play() {
        playbackState.isPlaying = true
        audioPlayer?.play()
    }
    
    func pause() {
        playbackState.isPlaying = false
        audioPlayer?.pause()
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
        playbackState.currentTime = targetTime
        
        if let player = audioPlayer {
            player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 1000))
        }
    }
    
    // MARK: - Sleep Timer
    func startSleepTimer(duration: TimeInterval) {
        cancelSleepTimer()
        playbackState.remainingTimerDuration = duration
        
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if let remaining = self.playbackState.remainingTimerDuration {
                if remaining <= 0 {
                    self.pause()
                    self.cancelSleepTimer()
                } else {
                    self.playbackState.remainingTimerDuration = remaining - 1
                }
            }
        }
    }
    
    func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        playbackState.remainingTimerDuration = nil
    }
    
    // MARK: - Progress Tracking
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.playbackState.currentTime = time.seconds
        }
    }
    
    // MARK: - Audio Effects
    private func performFadeOut() {
        guard let duration = TimeInterval(exactly: userPreferences.fadeOutDuration) else { return }
        
        let steps = 50
        let stepDuration = duration / Double(steps)
        let volumeDecrement = userPreferences.volume / Float(steps)
        
        var currentStep = 0
        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            currentStep += 1
            let newVolume = userPreferences.volume - (Float(currentStep) * volumeDecrement)
            self.audioPlayer?.volume = max(0, newVolume)
            
            if currentStep >= steps {
                timer.invalidate()
                self.pause()
                self.audioPlayer?.volume = self.userPreferences.volume
            }
        }
    }
    
    // MARK: - Cleanup
    deinit {
        if let timeObserver = timeObserver {
            audioPlayer?.removeTimeObserver(timeObserver)
        }
        sleepTimer?.invalidate()
    }
    
    // MARK: - State Management
    private func savePlaybackState() {
        playbackState.save()
    }
    
    func loadStory(_ story: Story) {
        currentStory = story
        let playerItem = AVPlayerItem(url: story.audioURL)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        // Remove previous time observer
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
        }
        
        // Add new time observer
        timeObserver = audioPlayer?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 1000),
            queue: .main
        ) { [weak self] time in
            self?.playbackState.currentTime = time.seconds
        }
    }
} 