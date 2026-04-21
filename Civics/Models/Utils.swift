import SwiftUI

enum AppStorageKey: String {
  case unionState
  case duration
}

struct Constants {
  static let backgroundGradient = LinearGradient(
    colors: [.background, .background.opacity(0.5)],
    startPoint: .top, endPoint: .bottom)
}

func extractNickname(from name: String) throws -> (String, String?) {
  var name = name
  var nickname: String? = nil

  let pattern = #"\"([^\"]+)\""#
  let regex = try? NSRegularExpression(pattern: pattern)
  if let match = regex?.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)),
    let range = Range(match.range(at: 1), in: name)
  {
    nickname = String(name[range])
    if let range = Range(match.range(at: 0), in: name) {
      name.removeSubrange(range)
    }
  }

  return (name, nickname)
}

func countdown(from start: Int) -> AsyncStream<Int> {
  AsyncStream { continuation in
    Task {
      for i in (0 ... start).reversed() {
        continuation.yield(i)
        try? await Task.sleep(for: .seconds(1))
      }
      continuation.finish()
    }
  }
}
