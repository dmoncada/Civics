import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss

  @Binding var selectedState: UnionState
  @Binding var selectedDuration: Int

  var body: some View {
    List {
      Section {
        StatePicker(selected: $selectedState)
        DurationPicker(selected: $selectedDuration)
      }
    }
  }
}

#Preview {
  @Previewable @State var showSheet = false
  @Previewable @State var state: UnionState = .wa
  @Previewable @State var duration = 120

  Button("Show Sheet") {
    showSheet = true
  }
  .sheet(isPresented: $showSheet) {
    SettingsView(
      selectedState: $state,
      selectedDuration: $duration
    )
    .presentationDetents([.fraction(1 / 3)])
  }
}
