import SwiftUI

struct CircularButtonStyle: PrimitiveButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button(action: { configuration.trigger() }) {
      configuration.label
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.circle)
  }
}

extension PrimitiveButtonStyle where Self == CircularButtonStyle {
  static var circular: CircularButtonStyle {
    CircularButtonStyle()
  }
}
