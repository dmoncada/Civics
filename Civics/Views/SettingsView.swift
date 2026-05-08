import SwiftUI

struct SettingsView: View {
  @Environment(Router.self) private var router
  @Environment(GameViewModel.self) private var vm

  @AppStorage(AppStorageKey.unionState.rawValue)
  private var state: UnionState = .wa

  @AppStorage(AppStorageKey.duration.rawValue)
  private var duration = 30

  @State var selectedState: UnionState = .wa
  @State var selectedDuration: Int = 30

  var body: some View {
    NavigationStack {
      List {
        Section {
          StatePicker(selected: $selectedState)
          DurationPicker(selected: $selectedDuration)
        } header: {
          Text("Test Settings")
        }
      }
      #if !os(macOS)
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            router.hideSheet()
          }
        }
      }
      #endif
    }
    .onAppear {
      selectedDuration = duration
    }
    .onChange(of: selectedDuration, initial: false) {
      duration = selectedDuration
    }
    .task(id: state) {
      try? await vm.setState(state)
    }
  }
}

#Preview {
  @Previewable @State var showSheet = false

  Button("Show Sheet") {
    showSheet = true
  }
  .sheet(isPresented: $showSheet) {
    SettingsView()
      .presentationDetents([.fraction(1 / 3)])
  }
  .environment(Router())
  .environment(GameViewModel())
}
