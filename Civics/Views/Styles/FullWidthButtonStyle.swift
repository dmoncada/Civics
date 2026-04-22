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
