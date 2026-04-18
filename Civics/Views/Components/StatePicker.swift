import SwiftUI

struct StatePicker: View {
  @Binding var selected: UnionState

  private let sorted = UnionState.allCases.sorted(using: KeyPathComparator(\.rawValue))

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
  @Previewable @State var state: UnionState = .WA
  StatePicker(selected: $state)
}
