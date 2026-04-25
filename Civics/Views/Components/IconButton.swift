import SwiftUI

enum AlignmentOffset {
  case vertical(CGFloat)
  case horizontal(CGFloat)
}

extension Array where Element == AlignmentOffset {
  var values: (x: CGFloat, y: CGFloat) {
    reduce((x: 0, y: 0)) { result, offset in
      switch offset {
      case .vertical(let y):
        return (x: result.x, y: result.y + y)
      case .horizontal(let x):
        return (x: result.x + x, y: result.y)
      }
    }
  }
}

struct IconButton: View {
  let systemImage: String
  let offsets: [AlignmentOffset]
  let action: () -> Void

  let size: CGFloat = 20

  init(
    systemImage: String,
    offset: AlignmentOffset,
    action: @escaping () -> Void
  ) {
    self.init(systemImage: systemImage, offsets: [offset], action: action)
  }

  init(
    systemImage: String,
    offsets: [AlignmentOffset] = [],
    action: @escaping () -> Void
  ) {
    self.systemImage = systemImage
    self.offsets = offsets
    self.action = action
  }

  var body: some View {
    let offset = offsets.values

    Button {
      action()

    } label: {
      Image(systemName: systemImage)
        // .font(.system(size: 24))
        .frame(width: size, height: size)
        .alignmentGuide(HorizontalAlignment.center) { d in d.width / 2 - offset.x }
        .alignmentGuide(VerticalAlignment.center) { d in d.height / 2 + offset.y }
    }
    .buttonStyle(.circular)
    .controlSize(.extraLarge)
  }
}

#Preview {
  HStack {
    IconButton(systemImage: "plus") {}
    IconButton(systemImage: "minus") {}
    IconButton(systemImage: "10.arrow.trianglehead.counterclockwise", offset: .vertical(1)) {}
    IconButton(systemImage: "10.arrow.trianglehead.counterclockwise", offsets: [.vertical(1)]) {}
  }
}
