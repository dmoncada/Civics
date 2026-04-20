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

enum IconAlignment {
  case none
  case vertical(CGFloat)
  case horizontal(CGFloat)
  case custom(x: CGFloat, y: CGFloat)

  var offset: (x: CGFloat, y: CGFloat) {
    switch self {
    case .none: return (0, 0)
    case .vertical(let y): return (0, y)
    case .horizontal(let x): return (x, 0)
    case .custom(let x, let y): return (x, y)
    }
  }
}

struct IconButton: View {
  let systemImage: String
  let alignment: IconAlignment
  let action: () -> Void

  let size: CGFloat = 20

  init(systemImage: String, alignment: IconAlignment = .none, action: @escaping () -> Void) {
    self.systemImage = systemImage
    self.alignment = alignment
    self.action = action
  }

  var body: some View {
    Button {
      action()
    } label: {
      Image(systemName: systemImage)
        .font(.system(size: 24))
        .frame(width: size, height: size)
        .alignmentGuide(HorizontalAlignment.center) { d in d.width / 2 - alignment.offset.x }
        .alignmentGuide(VerticalAlignment.center) { d in d.height / 2 + alignment.offset.y }
    }
    .buttonStyle(.circular)
    .controlSize(.extraLarge)
  }
}

#Preview {
  HStack {
    IconButton(systemImage: "plus") {}
    IconButton(systemImage: "minus") {}
    IconButton(systemImage: "10.arrow.trianglehead.counterclockwise", alignment: .vertical(1)) {}
  }
}
