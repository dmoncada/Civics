import SwiftUI

@main
struct CivicsApp: App {
  @State private var vm = GameViewModel()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(vm)
    }
  }
}
