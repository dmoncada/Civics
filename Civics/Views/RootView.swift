import SwiftUI

struct RootView: View {
  @Environment(GameViewModel.self) private var vm

  @AppStorage(AppStorageKey.unionState.rawValue)
  private var unionState: UnionState = .WA

  @AppStorage(AppStorageKey.duration.rawValue)
  private var duration = 30

  @State private var showSheet = false
  @State private var localDuration = 30

  var onComplete: () -> Void = {}

  var body: some View {
    VStack {
      Text("Civics")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundStyle(.primary)

      Text("Get Ready for your Test!")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundStyle(.secondary)
        .underline()

      HStack(spacing: 8) {
        IconButton(systemImage: "gearshape") {
          showSheet = true
        }
        .fontWeight(.bold)

        WideButton(title: "Start") {
          onComplete()
        }
        .fontWeight(.bold)
      }
    }
    .sheet(isPresented: $showSheet) {
      SettingsView(
        selectedState: $unionState,
        selectedDuration: $localDuration
      )
    }
    .onAppear() {
      localDuration = duration
    }
    .onChange(of: localDuration) {
      duration = localDuration
    }
    .task(id: unionState) {
      try? await vm.setState(unionState)
    }
  }
}

#Preview {
  ScreenContainer {
    RootView()
  }
  .environment(GameViewModel())
}
