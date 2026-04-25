import SwiftUI

struct WideButton: View {
  let title: String
  let action: () -> Void
  let systemImage: String?

  init(title: String, systemImage: String? = nil, action: @escaping () -> Void = {}) {
    self.title = title
    self.action = action
    self.systemImage = systemImage
  }

  var body: some View {
    Button {
      action()

    } label: {
      if let systemImage {
        Label(title, systemImage: systemImage)

      } else {
        Text(title)
      }
    }
    .buttonStyle(.fullWidth)
    .controlSize(.extraLarge)
  }
}

#Preview {
  WideButton(title: "Hello", action: {})
}
