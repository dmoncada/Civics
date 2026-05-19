import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationCoordinator()
      .onAppear {
        let audio = AudioManager.shared
        try? audio.configureSession()
        try? audio.preloadSounds()
      }
  }
}

#Preview {
  ContentView()
    .environment(GameViewModel())
}
