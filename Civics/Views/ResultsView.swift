import Subsonic
import SwiftUI

struct ResultsView: View {
  @Environment(GameViewModel.self) private var vm

  var onCompleted: () -> Void = {}

  var body: some View {
    VStack(spacing: 16) {
      let correctCount = vm.responses.count(where: \.correct)
      Text("You got ^[\(correctCount) question](inflect: true) \(getIcon(correctCount))")
        .font(.title2)
        .fontWeight(.bold)

      ScrollView(.vertical) {
        VStack(spacing: 8) {
          ForEach(vm.responses, id: \.index) { item in
            let (id, correct) = item
            let question = vm.question(id: id)
            let answers = vm.answers(for: id)

            DisclosureGroup {
              VStack(alignment: .leading, spacing: 8) {
                ForEach(answers, id: \.self) { answer in
                  AnswerRow(answer: answer, font: .system(size: 16))
                }
              }

            } label: {
              Text(question)
                .font(.title3)
                .multilineTextAlignment(.leading)
                .foregroundColor(correct ? .primary : .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disclosureGroupStyle(CustomDisclosureStyle())
          }
        }
        .padding()
      }

      WideButton(title: "Restart") {
        onCompleted()
      }
      .fontWeight(.bold)
    }
    .onAppear {
      play(sound: "marimba_shake.mp3")
    }
  }

  private func getIcon(_ count: Int) -> String {
    let questionsCount = GameViewModel.maxQuestionsCount
    let passingCount = GameViewModel.minPassingCount

    switch count {
    case ..<passingCount:
      return "😔"
    case passingCount ..< questionsCount:
      return "💪"
    case questionsCount...:
      return "🎉"
    default:
      break
    }

    return "Unreachable"
  }
}

#Preview {
  let vm = GameViewModel()
  vm.respond(true)
  vm.respond(true)
  vm.respond(false)

  return ScreenContainer {
    ResultsView()
  }
  .environment(vm)
  .task {
    try? await vm.setState(.wa)
  }
}
