import AVFoundation

class AudioManager {
  enum Error: Swift.Error {
    case fileNotFound(name: String)
  }

  static let shared = AudioManager()

  private let clips = [
    "gentle_click",
    "marimba_negative",
    "marimba_positive",
    "marimba_shake",
    "ta_da_brass",
  ]

  private init() {
    try? preloadClips()
  }

  private var players = [String: AVAudioPlayer]()

  func configureSession() throws {
    #if os(iOS)
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.ambient)
    #endif
  }

  func preloadClips() throws {
    try preload(clips: clips)
  }

  func preload(clips: [String]) throws {
    for clip in clips {
      try preload(clip: clip)
    }
  }

  func preload(clip: String) throws {
    guard players[clip] == nil else { return }
    guard let url = Bundle.main.url(forResource: clip, withExtension: "mp3") else {
      throw Error.fileNotFound(name: clip)
    }

    let player = try AVAudioPlayer(contentsOf: url)
    player.prepareToPlay()
    players[clip] = player
  }

  func play(clip: String) {
    if let player = players[clip] {
      player.stop()
      player.currentTime = 0
      player.play()
    }
  }
}

func play(clip: String) {
  AudioManager.shared.play(clip: clip)
}
