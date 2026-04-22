import SwiftUI

struct RootView: View {
  @Environment(GameViewModel.self) private var vm

  @AppStorage(AppStorageKey.unionState.rawValue)
  private var unionState: UnionState = .wa

  @AppStorage(AppStorageKey.duration.rawValue)
  private var duration = 30

  @State private var showSettings = false
  @State private var localDuration = 30

  var onComplete: () -> Void = {}

  var body: some View {
    VStack {
      Spacer()

      Text("Civics")
        .font(.largeTitle.bold())
        .foregroundStyle(.primary)

      Text("Get Ready for your Test!")
        .font(.title2.bold())
        .foregroundStyle(.secondary)
        .underline()

      Spacer()

      HStack(spacing: 8) {
        IconButton(systemImage: "gearshape") {
          showSettings = true
        }
        .bold()

        WideButton(title: "Start") {
          onComplete()
        }
        .bold()
      }
    }
    .sheet(isPresented: $showSettings) {
      SettingsView(
        selectedState: $unionState,
        selectedDuration: $localDuration
      )
      .presentationDetents([.fraction(1 / 3)])
    }
    .onAppear {
      localDuration = duration
    }
    .onChange(of: localDuration) {
      duration = localDuration
    }
    .task(id: unionState) {
      do {
        try await vm.setState(unionState)
      } catch {
        print(error)
      }
    }
  }
}

#Preview {
  ScreenContainer {
    RootView()
  }
  .environment(GameViewModel())
}
