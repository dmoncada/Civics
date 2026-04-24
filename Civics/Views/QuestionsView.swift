import SwiftUI

struct QuestionsView: View {
  @Environment(GameViewModel.self) private var vm

  @AppStorage(AppStorageKey.duration.rawValue)
  private var duration = 30

  @State private var timeRemaining = 0

  var onComplete: () -> Void = {}

  var body: some View {
    verticalContent
      .onChange(of: vm.responses.count) {
        guard timeRemaining > 0 else { return }

        // if vm.isPassing || vm.isFailing {
        //     onComplete()
        // }

        if vm.responses.count == GameViewModel.maxQuestionsCount {
          onComplete()
        }
      }
      .task {
        for await i in countdown(from: duration) {
          timeRemaining = i
        }

        if timeRemaining == 0 {
          vm.respond(false)
          onComplete()
        }
      }
  }
}

extension QuestionsView {
  fileprivate var verticalContent: some View {
    VStack(spacing: 16) {
      Text(vm.currentQuestion.replaceEmphasized(with: .underline))
        .font(.title2.bold())
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .frame(height: 150)

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 8) {
          ForEach(vm.currentAnswers, id: \.self) { answer in
            AnswerRow(answer: answer, font: .title3)
          }
        }
      }

      countdownTimer

      progressBar

      HStack {
        responseButton(true)
        responseButton(false)
      }
    }
  }

  @ViewBuilder
  fileprivate func responseButton(_ correct: Bool) -> some View {
    let title = correct ? "Correct" : "Incorrect"
    let tint = correct ? Color.correct : .incorrect
    let clip = "marimba_\(correct ? "positive" : "negative")"

    WideButton(title: title) {
      vm.respond(correct)

      // if vm.isPassing == false && vm.isFailing == false {
      //  play(clip: clip)
      // }

      if vm.responses.count < GameViewModel.maxQuestionsCount {
        play(clip: clip)
      }
    }
    .foregroundStyle(.primary)
    .fontWeight(.bold)
    .tint(tint)
  }

  @ViewBuilder
  private var progressBar: some View {
    let count = vm.responses.count
    let total = GameViewModel.maxQuestionsCount
    let responses = vm.responses.map { $0.correct }

    CustomProgressView(responses: responses, total: total)
      .animation(.default, value: count)
  }

  @ViewBuilder
  fileprivate var countdownTimer: some View {
    let duration = Duration.seconds(timeRemaining)
    let formatted = duration.formatted(.time(pattern: .minuteSecond))

    Text(formatted)
      .font(.title.bold())
      .monospacedDigit()
  }
}

#Preview {
  let vm = GameViewModel()
  return ScreenContainer {
    QuestionsView()
  }
  .environment(vm)
  .task {
    try? await vm.setState(.wa)
  }
}
