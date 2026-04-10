import SwiftUI

struct CountdownView: View {
  var onComplete: () -> Void = {}

  @State private var value: Int = 3

  var body: some View {
    ZStack {
      Color.blue.ignoresSafeArea()

      let text = value > 0 ? value.description : "Go"

      Text(text)
        .contentTransition(.numericText(countsDown: true))
        .font(.system(size: 120, weight: .bold))
        .foregroundStyle(.white)
        .scaledToFit()
    }
    .task {
      for await i in countdown(from: 3) {
        withAnimation {
          value = i
        }
      }

      try? await Task.sleep(for: .seconds(1))
      onComplete()
    }
  }
}

#Preview {
  CountdownView()
}
