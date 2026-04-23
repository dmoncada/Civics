import SwiftUI

enum Screen: Hashable {
  case prepare
  case countdown
  case questions
  case results
}

struct ContentView: View {
  @Environment(GameViewModel.self) private var vm

  @State private var path = NavigationPath()

  var body: some View {
    NavigationStack(path: $path) {
      ScreenContainer {
        RootView {
          path.append(Screen.prepare)
        } onTest: {
          path.append(Screen.countdown)
        }
      }
      .navigationDestination(for: Screen.self) { screen in
        screenView(for: screen)
      }
    }
    .onAppear {
      let audio = AudioManager.shared
      try? audio.configureSession()
      try? audio.preloadClips()
    }
    .onChange(of: path) {
      if path.isEmpty {
        vm.reset()
      }
    }
  }

  @ViewBuilder
  private func screenView(for screen: Screen) -> some View {
    Group {
      switch screen {
      case .prepare:
        ScreenContainer {
          PreparationView()
        }

      case .countdown:
        ScreenContainer {
          CountdownView {
            path.append(Screen.questions)
          }
        }
        .navigationBarBackButtonHidden()

      case .questions:
        ScreenContainer {
          QuestionsView {
            path.append(Screen.results)
          }
        }
        .navigationBarBackButtonHidden()

      case .results:
        ScreenContainer {
          ResultsView {
            path = NavigationPath()
          }
        }
        .navigationBarBackButtonHidden()
      }
    }
  }
}

#Preview {
  ContentView()
    .environment(GameViewModel())
}
