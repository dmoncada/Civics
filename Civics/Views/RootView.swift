import SwiftUI

struct RootView: View {
  @Environment(GameViewModel.self) private var vm

  @AppStorage(AppStorageKey.unionState.rawValue)
  private var unionState: UnionState = .wa

  @AppStorage(AppStorageKey.duration.rawValue)
  private var storedDuration = 30

  @State private var duration = 30
  @State private var showSettings = false

  var onPrep: () -> Void = {}
  var onTest: () -> Void = {}

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

        WideButton(title: "Prep") {
          onPrep()
        }
        .bold()

        WideButton(title: "Test") {
          onTest()
        }
        .bold()
      }
    }
    .sheet(isPresented: $showSettings) {
      SettingsView(
        selectedState: $unionState,
        selectedDuration: $duration
      )
      .presentationDetents([.fraction(1 / 3)])
    }
    .onAppear {
      duration = storedDuration
    }
    .onChange(of: duration) {
      storedDuration = duration
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
