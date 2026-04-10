import SwiftUI

struct StatePicker: View {
  @Binding var selected: UnionState

  private let sorted = UnionState.allCases.sorted { $0.rawValue < $1.rawValue }

  var body: some View {
    Picker("State", selection: $selected) {
      ForEach(sorted, id: \.self) { state in
        Text("\(state.rawValue) (\(state.description))")
          .tag(state)
      }
    }
  }
}

#Preview {
  struct Wrapper: View {
    @State private var state: UnionState = .WA

    var body: some View {
      StatePicker(selected: $state)
    }
  }

  return Wrapper()
}
