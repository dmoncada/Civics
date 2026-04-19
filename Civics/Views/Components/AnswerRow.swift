import SwiftUI

struct AnswerRow: View {
  let answer: String
  let font: Font

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 4) {
      Text("🇺🇸")
        .font(font)
        .scaleEffect(0.75)

      Text(answer)
        .font(font)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  VStack {
    AnswerRow(answer: "Answer 1", font: .title)
    AnswerRow(answer: "Answer 2", font: .title2)
    AnswerRow(answer: "Answer 3", font: .title3)
  }
}
