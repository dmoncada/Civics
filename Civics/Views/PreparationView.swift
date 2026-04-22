import SwiftUI

struct PreparationView: View {
  @Environment(GameViewModel.self) private var vm

  @State private var currentIndex: Int? = 0
  @State private var flippedCards: Set<Int> = []

  private let step = 10
  private let cardHeight: CGFloat = 400
  private let cardMaxWidth: CGFloat = 200

  var body: some View {
    VStack(spacing: 16) {
      GeometryReader { reader in
        let sideInset = (reader.size.width - cardMaxWidth) / 2

        ScrollView(.horizontal) {
          LazyHStack(spacing: 16) {
            ForEach(0 ..< vm.count, id: \.self) { i in
              cardView(for: i, isFlipped: flippedCards.contains(i))
                .id(i)
                .onTapGesture {
                  if flippedCards.remove(i) == nil {
                    flippedCards.insert(i)
                  }
                }
            }
          }
          .scrollTargetLayout()
        }
        .contentMargins(.horizontal, sideInset)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $currentIndex)
      }

      HStack(spacing: 4) {
        WideButton(title: "First") {
          updateIndex(0)
        }
        .bold()

        IconButton(systemImage: "10.arrow.trianglehead.counterclockwise", offsets: [.vertical(1)]) {
          let index = currentIndex ?? 0
          updateIndex(index - step)
        }

        IconButton(systemImage: "10.arrow.trianglehead.clockwise", offsets: [.vertical(1)]) {
          let index = currentIndex ?? 0
          updateIndex(index + step)
        }

        WideButton(title: "Last") {
          updateIndex(vm.count - 1)
        }
        .bold()
      }
    }
  }
}

extension PreparationView {
  fileprivate func updateIndex(_ next: Int) {
    let next = next.clamped(to: 0 ... vm.count - 1)
    withAnimation(.easeInOut(duration: 0.75)) {
      currentIndex = next
    }
  }

  @ViewBuilder
  fileprivate func cardView(for id: Int, isFlipped: Bool) -> some View {
    let question = vm.question(id: id)
    let answers = vm.answers(for: id)

    FlippableCard(isFlipped: isFlipped) {
      cardFront(question, id: id)

    } back: {
      cardBack(answers)
        .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
    }
    .frame(height: cardHeight)
    .frame(maxWidth: cardMaxWidth)
  }

  fileprivate func cardFront(_ question: String, id: Int) -> some View {
    ZStack {
      cardBackground(.red)

      VStack {
        Text("Question #\(id + 1)")
          .font(.caption)
          .padding(.top, 8)

        Spacer()

        Text(question.replaceEmphasized(with: .underline))
          .multilineTextAlignment(.center)
          .foregroundStyle(.primary)
          .font(.title3.bold())

        Spacer()
      }
      .padding()
    }
  }

  fileprivate func cardBack(_ answers: [String]) -> some View {
    ZStack {
      cardBackground(.blue)

      ViewThatFits(in: .vertical) {
        answerStack(answers)

        ScrollView(.vertical) {
          answerStack(answers)
        }
      }
      .padding()
    }
  }

  fileprivate func answerStack(_ answers: [String]) -> some View {
    VStack(alignment: .center, spacing: 8) {
      ForEach(answers, id: \.self) { answer in
        AnswerRow(answer: answer, font: .body)
      }
    }
  }

  @ViewBuilder
  fileprivate func cardBackground(_ color: Color) -> some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(.white)

    RoundedRectangle(cornerRadius: 12)
      .fill(color)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .fill(.white.opacity(0.5))
      )
      .padding(8)
  }
}

#Preview {
  let vm = GameViewModel()
  ScreenContainer {
    PreparationView()
  }
  .environment(vm)
  .task {
    try? await vm.setState(.wa)
  }
}
