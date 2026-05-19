import AVFoundation

final class AudioManager {
  enum Error: Swift.Error {
    case fileNotFound(Sound)
    case soundNotLoaded(AudioManager.Sound)
  }

  enum Sound: String, CaseIterable {
    case uiSfxTick = "gentle_click"
    case uiSfxTapCorrect = "marimba_positive"
    case uiSfxTapIncorrect = "marimba_negative"
    case uiSfxFailure = "marimba_shake"
    case uiSfxSuccess = "ta_da_brass"
  }

  static let shared = AudioManager()

  private var players: [Sound: AVAudioPlayer] = [:]

  func configureSession() throws {
    #if os(iOS)
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.ambient)
    try session.setActive(true)
    #endif
  }

  func preloadSounds() throws {
    for sound in Sound.allCases {
      try preload(sound)
    }
  }

  private func preload(_ sound: Sound) throws {
    guard players[sound] == nil else { return }

    guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3")
    else { throw Error.fileNotFound(sound) }

    let player = try AVAudioPlayer(contentsOf: url)
    player.prepareToPlay()

    players[sound] = player
  }

  func play(_ sound: Sound) throws {
    guard let player = players[sound]
    else { throw Error.soundNotLoaded(sound) }

    if player.isPlaying {
      player.stop()
    }

    player.currentTime = 0
    player.play()
  }

  func setVolume(_ volume: Float, for sound: Sound) {
    players[sound]?.volume = volume
  }
}

func play(_ sound: AudioManager.Sound) throws {
  try AudioManager.shared.play(sound)
}
