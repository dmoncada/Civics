import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationCoordinator()
      .onAppear {
        let audio = AudioManager.shared
        try? audio.configureSession()
        try? audio.preloadClips()
      }
  }
}

#Preview {
  ContentView()
    .environment(GameViewModel())
}
