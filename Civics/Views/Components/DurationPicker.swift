import SwiftUI

struct DurationPicker: View {
  @Binding var selected: Int

  private let values = Array(stride(from: 30, through: 300, by: 30))

  var body: some View {
    HStack(spacing: 8) {
      IconButton(systemImage: "minus") {
        decrement()
      }
      .disabled(isMin)

      let duration = Duration.seconds(selected)

      Text(duration.formatted(.time(pattern: .minuteSecond)))
        .font(.system(size: 40, weight: .semibold, design: .rounded))
        .contentTransition(.numericText())
        .monospacedDigit()

      IconButton(systemImage: "plus") {
        increment()
      }
      .disabled(isMax)
    }
  }

  private var currentIndex: Int {
    values.firstIndex(of: selected) ?? 0
  }

  private var isMin: Bool {
    currentIndex == 0
  }

  private var isMax: Bool {
    currentIndex == values.count - 1
  }

  private func increment() {
    if isMax { return }
    withAnimation {
      selected = values[currentIndex + 1]
    }
  }

  private func decrement() {
    if isMin { return }
    withAnimation {
      selected = values[currentIndex - 1]
    }
  }
}

#Preview {
  @Previewable @State var selected = 30
  DurationPicker(selected: $selected)
}
