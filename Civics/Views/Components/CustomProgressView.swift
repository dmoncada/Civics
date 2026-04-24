import SwiftUI

struct CustomProgressView: View {
  let responses: [Bool?]

  private let total: Int
  private let spacing: CGFloat = 6
  private let maxWidth: CGFloat = 500
  private let maxHeight: CGFloat = 24

  init(responses: [Bool], total: Int = 20) {
    let padding: [Bool?] = Array(repeating: nil, count: max(0, total - responses.count))
    self.responses = responses + padding
    self.total = total
  }

  var body: some View {
    VStack(spacing: 0) {
      GeometryReader { geo in
        let width = min(geo.size.width, maxWidth)
        let totalSpacing = spacing * CGFloat(total - 1)
        let itemWidth = (width - totalSpacing) / CGFloat(total)

        HStack(spacing: spacing) {
          ForEach(responses.indices, id: \.self) { index in
            Rectangle()
              .fill(color(for: responses[index]))
              .frame(width: itemWidth, height: itemWidth)
          }
        }
        .frame(width: width)
        .frame(maxHeight: maxHeight)
      }
      .frame(maxHeight: maxHeight)

      HStack {
        Label("**\(correctCount)** correct")
        Spacer()
        Label("**\(incorrectCount)** incorrect")
      }
      .frame(maxWidth: maxWidth)
    }
  }

  @ViewBuilder
  private func Label(_ text: String) -> some View {
    let attributed = (try? AttributedString(markdown: text)) ?? AttributedString(text)

    Text(attributed)
      .font(.footnote)
      .foregroundStyle(.gray)
      .monospacedDigit()
      .contentTransition(.numericText())
  }

  private var correctCount: Int { responses.count(where: { $0 == true }) }
  private var incorrectCount: Int { responses.count(where: { $0 == false }) }

  private func color(for correct: Bool?) -> Color {
    switch correct {
    case true: return .correct
    case false: return .incorrect
    case nil: return Color.gray.opacity(0.25)
    }
  }
}

#Preview {
  let responses = [true, true, true, false]
  CustomProgressView(responses: responses, total: 20)
    .padding()
}
