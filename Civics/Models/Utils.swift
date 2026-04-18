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
