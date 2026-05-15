import AVFoundation
import Foundation

@MainActor
final class SpeechSynthesizer {
  private let synthesizer = AVSpeechSynthesizer()
  private var delegate: SpeechDelegate?
  private var continuation: CheckedContinuation<Void, Never>?

  init() {}

  private func setupDelegate() {
    if delegate == nil {
      delegate = SpeechDelegate { [weak self] in
        self?.didFinishSpeaking()
      }
      synthesizer.delegate = delegate
    }
  }

  func speak(
    text: String,
    langCode: String,
    rate: Float = AVSpeechUtteranceDefaultSpeechRate
  ) async {
    setupDelegate()
    synthesizer.stopSpeaking(at: .immediate)

    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: langCode)
    utterance.rate = rate

    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      self.continuation = continuation
      synthesizer.speak(utterance)
    }
  }

  func stop() {
    synthesizer.stopSpeaking(at: .immediate)
    continuation?.resume()
    continuation = nil
  }

  private func didFinishSpeaking() {
    continuation?.resume()
    continuation = nil
  }
}

private final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
  private let onFinish: @MainActor () -> Void

  init(onFinish: @escaping @MainActor () -> Void) {
    self.onFinish = onFinish
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance
  ) {
    Task { @MainActor in
      onFinish()
    }
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance
  ) {
    Task { @MainActor in
      onFinish()
    }
  }
}
