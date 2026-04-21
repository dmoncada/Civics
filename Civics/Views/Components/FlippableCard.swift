import SwiftUI

struct FlippableCard<Front: View, Back: View>: View {
  let isFlipped: Bool
  let front: Front
  let back: Back

  init(
    isFlipped: Bool,
    @ViewBuilder front: () -> Front,
    @ViewBuilder back: () -> Back
  ) {
    self.isFlipped = isFlipped
    self.front = front()
    self.back = back()
  }

  var body: some View {
    ZStack {
      front
        .opacity(isFlipped ? 0 : 1)

      back
        .opacity(isFlipped ? 1 : 0)
    }
    .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (0, 1, 0))
    .animation(.bouncy(duration: 0.5), value: isFlipped)
  }
}

#Preview {
  @Previewable @State var isFlipped = false

  FlippableCard(isFlipped: isFlipped) {
    ZStack {
      RoundedRectangle(cornerRadius: 16)
        .fill(.blue)

      Text("Question")
        .foregroundStyle(.white)
        .padding()
    }

  } back: {
    ZStack {
      RoundedRectangle(cornerRadius: 16)
        .fill(.green)

      VStack {
        ForEach(Array(1 ... 3), id: \.self) { number in
          Text("Answer #\(number)")
        }
      }
      .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
    }
  }
  .frame(width: 150, height: 300)
  .onTapGesture {
    isFlipped.toggle()
  }
}
