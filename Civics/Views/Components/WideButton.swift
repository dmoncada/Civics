import SwiftUI

struct WideButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(title, action: action)
      .buttonStyle(.fullWidth)
      .controlSize(.extraLarge)
  }
}

#Preview {
  WideButton(title: "Hello", action: {})
}
