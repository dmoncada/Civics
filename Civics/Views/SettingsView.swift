import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss

  @Binding var selectedState: UnionState
  @Binding var selectedDuration: Int

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      StatePicker(selected: $selectedState)
      DurationPicker(selected: $selectedDuration)
    }
    .presentationDetents([.medium])
  }
}

#Preview {
  @Previewable @State var showSheet = false
  @Previewable @State var state: UnionState = .WA
  @Previewable @State var duration = 120

  Button("Show Sheet") {
    showSheet = true
  }
  .sheet(isPresented: $showSheet) {
    SettingsView(
      selectedState: $state,
      selectedDuration: $duration
    )
  }
}
