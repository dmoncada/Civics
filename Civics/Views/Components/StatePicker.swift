import SwiftUI

struct StatePicker: View {
  @Binding var selected: UnionState

  private let sorted = UnionState.allCases.sorted(using: KeyPathComparator(\.code))

  var body: some View {
    Picker("State", selection: $selected) {
      ForEach(sorted, id: \.self) { state in
        Text("\(state.code) (\(state.rawValue))")
          .tag(state)
      }
    }
  }
}

#Preview {
  @Previewable @State var state: UnionState = .wa
  StatePicker(selected: $state)
}
