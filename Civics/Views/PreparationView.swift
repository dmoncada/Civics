import SwiftUI

struct PreparationView: View {
  @State var vm = GameViewModel()

  @State private var currentIndex: Int? = 0
  @State private var flippedCards: Set<Int> = []

  private let step = 10

  var body: some View {
    VStack(spacing: 16) {
      GeometryReader { reader in
        let sideInset = (reader.size.width - 250) / 2

        ScrollView(.horizontal) {
          LazyHStack(spacing: 16) {
            ForEach(0 ..< vm.count, id: \.self) { i in
              cardView(for: i, isFlipped: flippedCards.contains(i))
                .id(i)
                .onTapGesture {
                  if flippedCards.contains(i) {
                    flippedCards.remove(i)
                  } else {
                    flippedCards.insert(i)
                  }
                }
            }
          }
          .scrollTargetLayout()
        }
        .border(.blue)
        .contentMargins(.horizontal, sideInset)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $currentIndex)
      }

      HStack(spacing: 4) {
        WideButton(title: "First") {
          updateIndex(0)
        }

        IconButton(systemImage: "10.arrow.trianglehead.counterclockwise", offset: .vertical(1)) {
          let index = currentIndex ?? 0
          updateIndex(index - step)
        }

        IconButton(systemImage: "10.arrow.trianglehead.clockwise", offset: .vertical(1)) {
          let index = currentIndex ?? 0
          updateIndex(index + step)
        }

        WideButton(title: "Last") {
          updateIndex(vm.count - 1)
        }
      }
    }
  }

  func updateIndex(_ next: Int) {
    let next = max(0, min(vm.count - 1, next))
    withAnimation(.easeInOut(duration: 0.75)) {
      currentIndex = next
    }
  }

  @ViewBuilder
  func cardView(for id: Int, isFlipped: Bool) -> some View {
    let question = vm.question(id: id)
    let answers = vm.answers(for: id)

    FlippableCard(isFlipped: isFlipped) {
      frontView(question, id: id)

    } back: {
      backView(answers)
        .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
    }
    .frame(width: 250, height: 500)
  }

  func frontView(_ question: String, id: Int) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16)
        .fill(.red.opacity(0.5))

      VStack {
        Text("Question #\(id + 1)")
        Text(question.replaceEmphasized(with: .underline))
          .multilineTextAlignment(.center)
          .foregroundStyle(.primary)
          .font(.title2.bold())
          .border(.red)
      }
    }
  }

  func backView(_ answers: [String]) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16)
        .fill(.blue.opacity(0.5))

      VStack(alignment: .leading, spacing: 8) {
        ForEach(answers, id: \.self) { answer in
          AnswerRow(answer: answer, font: .title3)
        }
      }
      .border(.red)
    }
  }
}

#Preview {
  let vm = GameViewModel()
  ScreenContainer {
    PreparationView(vm: vm)
  }
  .task {
    try? await vm.setState(.wa)
  }
}
