import SwiftUI

struct ScreenContainer<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    ZStack {
      Color.background.ignoresSafeArea()

      content.padding()
    }
  }
}
