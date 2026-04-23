import SwiftUI

struct DurationPicker: View {
  @Binding var selected: Int

  private let values = Array(stride(from: 30, through: 300, by: 30))

  var body: some View {
    Stepper {
      let duration = Duration.seconds(selected)
      let formatted = duration.formatted(.time(pattern: .minuteSecond))
      Text("Time: \(formatted)")
        .contentTransition(.numericText())
        .monospacedDigit()

    } onIncrement: {
      increment()

    } onDecrement: {
      decrement()
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
