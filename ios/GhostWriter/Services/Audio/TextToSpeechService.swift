import Foundation
import AVFoundation
import Observation

/// Text-to-speech service using the system speech synthesizer.
///
/// Wraps `AVSpeechSynthesizer` to read text aloud with selectable voices.
@Observable
final class TextToSpeechService: NSObject, @unchecked Sendable, AVSpeechSynthesizerDelegate {

    /// Whether the synthesizer is currently speaking.
    var isSpeaking: Bool = false

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Speaks the provided text using the specified voice.
    ///
    /// Stops any in-progress speech before starting. Completes when
    /// the synthesizer finishes speaking.
    ///
    /// - Parameters:
    ///   - text: The text to speak.
    ///   - voiceId: An `AVSpeechSynthesisVoice` identifier string.
    func speak(_ text: String, voiceId: String = "default") async {
        stop()

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.8

        if voiceId != "default",
           let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        isSpeaking = true
        synthesizer.speak(utterance)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.speakingContinuation = continuation
        }
    }

    /// Immediately stops any in-progress speech.
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        speakingContinuation?.resume()
        speakingContinuation = nil
    }

    /// Returns the identifiers of all available speech synthesis voices.
    ///
    /// - Returns: An array of voice identifier strings.
    func availableVoices() -> [String] {
        AVSpeechSynthesisVoice.speechVoices().map(\.identifier)
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        isSpeaking = false
        speakingContinuation?.resume()
        speakingContinuation = nil
    }

    // MARK: - Private

    private var speakingContinuation: CheckedContinuation<Void, Never>?
}
