import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss

  @Binding var selectedState: UnionState
  @Binding var selectedDuration: Int

  var body: some View {
    VStack(spacing: 24) {
      HStack {
        Text("Select State:")
          .font(.title2)

        Spacer()

        StatePicker(selected: $selectedState)
      }

      HStack {
        Text("Select Duration:")
          .font(.title2)

        Spacer()

        DurationPicker(selected: $selectedDuration)
      }

      Button("Dismiss") {
        dismiss()
      }
      .font(.title3)
      .padding(.top)
    }
    .padding(.horizontal, 48)
    .presentationDetents([.medium])
  }
}

#Preview {
  struct Wrapper: View {
    @State private var showSheet = false
    @State private var state: UnionState = .WA
    @State private var duration = 120

    var body: some View {
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
  }

  return Wrapper()
}
