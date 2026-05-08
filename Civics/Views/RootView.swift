import SwiftUI

struct RootView: View {
  @Environment(Router.self) private var router
  @Environment(GameViewModel.self) private var vm

  var body: some View {
    VStack {
      Spacer()

      Text("Civics")
        .font(.largeTitle.bold())
        .foregroundStyle(.primary)

      Text("Prepare for your Test!")
        .font(.title2.bold())
        .foregroundStyle(.secondary)
        .underline()

      Spacer()

      HStack(spacing: 8) {
        IconButton(systemImage: "gearshape") {
          router.showSheet(destination: Sheet.settings)
        }

        WideButton(title: "Prep", systemImage: "book") {
          router.navigate(to: Screen.prepare)
        }
        .bold()

        WideButton(title: "Test", systemImage: "person.2") {
          router.navigate(to: Screen.countdown)
        }
        .bold()
      }
    }
  }
}

#Preview {
  ScreenContainer {
    RootView()
  }
  .environment(Router())
  .environment(GameViewModel())
}
