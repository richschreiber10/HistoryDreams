import AVFoundation

class AudioManager {
    private var player: AVAudioPlayer?
    private var playbackState = PlaybackState()

    func play(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            playbackState.isPlaying = true
            playbackState.currentTime = 0
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }

    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        playbackState.isPlaying = false
        playbackState.currentTime = 0
    }
    
    func fadeOutAndStop(duration: TimeInterval = 5.0) {
        guard let player = player else { return }
        
        let originalVolume = player.volume
        let fadeSteps = 50
        let stepDuration = duration / TimeInterval(fadeSteps)
        let volumeDecrement = originalVolume / Float(fadeSteps)
        
        func fadeStep(stepsRemaining: Int) {
            guard stepsRemaining > 0 else {
                self.stop()
                player.volume = originalVolume
                return
            }
            
            player.volume -= volumeDecrement
            
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
                fadeStep(stepsRemaining: stepsRemaining - 1)
            }
        }
        
        fadeStep(stepsRemaining: fadeSteps)
    }
} 