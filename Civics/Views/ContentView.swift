import SwiftUI

enum Screen: Hashable {
  case load
  case questions
  case results
}

struct NavigationController: View {
  @State private var path = NavigationPath()
  @State private var vm = GameViewModel()

  var body: some View {
    NavigationStack(path: $path) {
      RootView(vm: vm) {
        path.append(Screen.load)
      }
      .navigationDestination(for: Screen.self) { screen in
        screenView(for: screen)
      }
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
      case .load:
        CountdownView {
          path.append(Screen.questions)
        }
      case .questions:
        QuestionsView(vm: vm) {
          path.append(Screen.results)
        }
      case .results:
        ResultsView(vm: vm) {
          path = NavigationPath()
        }
      }
    }
    .navigationBarBackButtonHidden()
  }
}

struct ContentView: View {
  var body: some View {
    NavigationController()
  }
}

#Preview {
  ContentView()
}
