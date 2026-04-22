import SwiftUI

struct CustomDisclosureStyle: DisclosureGroupStyle {
  func makeBody(configuration: Configuration) -> some View {
    VStack {
      Button {
        withAnimation {
          configuration.isExpanded.toggle()
        }

      } label: {
        HStack(alignment: .firstTextBaseline) {
          configuration.label

          Spacer()

          Image(systemName: "chevron.right")
            .fontWeight(.medium)
            .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
            .animation(.easeInOut(duration: 0.25), value: configuration.isExpanded)
        }
        .contentShape(Rectangle())
        .padding(.bottom, 1)
      }
      .buttonStyle(.plain)

      if configuration.isExpanded {
        configuration.content
      }
    }
  }
}

extension DisclosureGroupStyle where Self == CustomDisclosureStyle {
  static var custom: CustomDisclosureStyle {
    CustomDisclosureStyle()
  }
}
