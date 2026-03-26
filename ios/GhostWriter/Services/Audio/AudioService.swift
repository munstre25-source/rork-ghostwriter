import Foundation
import AVFoundation
import Observation

/// Manages ambient sound playback and creative UI sound effects.
///
/// Uses system sounds as placeholders. The architecture supports loading
/// custom audio assets for ambient sounds and milestone effects.
@Observable
final class AudioService: @unchecked Sendable {

    /// Whether ambient audio is currently playing.
    var isPlaying: Bool = false

    private var audioPlayer: AVAudioPlayer?

    /// Plays a looping ambient sound track by name.
    ///
    /// - Parameter named: The name of the ambient sound resource.
    func playAmbientSound(named: String) async {
        stopAmbient()

        if let url = Bundle.main.url(forResource: named, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = 0.3
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("[AudioService] Failed to play ambient sound '\(named)': \(error)")
            }
        } else {
            print("[AudioService] Ambient sound '\(named)' not found, simulating playback.")
            isPlaying = true
        }
    }

    /// Stops any currently playing ambient sound.
    func stopAmbient() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }

    /// Plays a short sound when a new suggestion appears.
    func playSuggestionAppearSound() {
        playSystemSound(id: 1057)
    }

    /// Plays a celebratory sound when the user reaches a milestone.
    func playMilestoneSound() {
        playSystemSound(id: 1025)
    }

    /// Plays a subtle sound indicating the user has entered a flow state.
    func playFlowStateSound() {
        playSystemSound(id: 1054)
    }

    // MARK: - Private

    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}
