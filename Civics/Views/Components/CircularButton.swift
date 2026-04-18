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

struct IconButton: View {
  let systemImage: String
  let action: () -> Void

  let size: CGFloat = 20

  var body: some View {
    Button {
      action()
    } label: {
      Image(systemName: systemImage)
        .font(.system(size: 24))
        .frame(width: size, height: size)
    }
    .buttonStyle(.circular)
    .controlSize(.extraLarge)
  }
}

#Preview {
  HStack {
    IconButton(systemImage: "plus") {}
    IconButton(systemImage: "minus") {}
  }
}
