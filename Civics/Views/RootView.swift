import SwiftUI

struct RootView: View {
  @AppStorage(AppStorageKey.unionState.rawValue)
  private var unionState: UnionState = .WA

  @AppStorage(AppStorageKey.duration.rawValue)
  private var duration = 30

  @State private var showSheet = false

  var vm: GameViewModel
  var onComplete: () -> Void = {}

  var body: some View {
    ZStack {
      Color.blue.ignoresSafeArea()

      VStack {
        Spacer()

        HStack(spacing: 24) {
          CircularButton(systemImage: "gear") {
            showSheet = true
          }

          Button {
            onComplete()
          } label: {
            Text("Start")
              .font(.title)
              .frame(width: 256, height: 56)
              .foregroundStyle(.white)
              .background(.teal)
              .cornerRadius(24)
              .bold()
          }
        }

        Spacer()
      }
    }
    .sheet(isPresented: $showSheet) {
      SettingsView(
        selectedState: $unionState,
        selectedDuration: $duration
      )
    }
    .task(id: unionState) {
      try? await vm.setState(unionState)
    }
  }
}

#Preview {
  struct Wrapper: View {
    var body: some View {
      RootView(vm: GameViewModel()) {}
    }
  }

  return Wrapper()
}
