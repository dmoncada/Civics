import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss

  @Binding var selectedState: UnionState
  @Binding var selectedDuration: Int

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
      .navigationTitle("Settings")
      #if !os(macOS)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
      #endif
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
