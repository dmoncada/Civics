import SwiftUI

struct TimerPickerView: View {
  @Binding var selectedDuration: Int
  private let durations = stride(from: 30, through: 300, by: 30).map { $0 }

  var body: some View {
    VStack(spacing: 20) {
      Text("Select Session Length")
        .font(.headline)

      Picker("Duration", selection: $selectedDuration) {
        ForEach(durations, id: \.self) { seconds in
          Text(formatDuration(seconds)).tag(seconds)
        }
      }
      .pickerStyle(.menu)  // Cross-platform
      .frame(maxWidth: 200)

      Text("Selected: \(formatDuration(selectedDuration))")
    }
    .padding()
  }

  private func formatDuration(_ seconds: Int) -> String {
    if seconds < 60 { return "\(seconds)s" }
    let minutes = seconds / 60
    let leftover = seconds % 60
    return leftover == 0 ? "\(minutes) min" : "\(minutes) min \(leftover)s"
  }
}
