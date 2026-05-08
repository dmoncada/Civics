import SwiftUI

enum Screen: Hashable {
  case prepare
  case countdown
  case questions
  case results
}

enum Sheet: String, Identifiable {
  case settings

  var id: String { self.rawValue }
}

struct NavigationCoordinator: View {
  @Environment(GameViewModel.self) private var vm

  @State private var router = Router()

  var body: some View {
    NavigationStack(path: $router.path) {
      ScreenContainer {
        RootView()
      }
      .navigationDestination(for: Screen.self) { screen in
        screenView(for: screen)
      }
    }
    .sheet(item: router.sheetItem) { _ in
      SettingsView()
        .presentationDetents([.fraction(1 / 3)])
    }
    .onChange(of: router.path) {
      if router.path.isEmpty {
        vm.reset()
      }
    }
    .environment(router)
  }
}

extension NavigationCoordinator {
  @ViewBuilder
  fileprivate func screenView(for screen: Screen) -> some View {
    Group {
      switch screen {
      case .prepare:
        ScreenContainer {
          PreparationView()
        }

      case .countdown:
        ScreenContainer {
          CountdownView {
            router.navigate(to: Screen.questions)
          }
        }
        .navigationBarBackButtonHidden()

      case .questions:
        ScreenContainer {
          QuestionsView {
            router.navigate(to: Screen.results)
          }
        }
        .navigationBarBackButtonHidden()

      case .results:
        ScreenContainer {
          ResultsView {
            router.navigateToRoot()
          }
        }
        .navigationBarBackButtonHidden()
      }
    }
  }
}

#Preview {
  NavigationCoordinator()
    .environment(GameViewModel())
}
