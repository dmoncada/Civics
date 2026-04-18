import SwiftUI

struct FullWidthButtonStyle: PrimitiveButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button(action: { configuration.trigger() }) {
      configuration.label
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
  }
}

extension PrimitiveButtonStyle where Self == FullWidthButtonStyle {
  static var fullWidth: FullWidthButtonStyle {
    FullWidthButtonStyle()
  }
}

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
