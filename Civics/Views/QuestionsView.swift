import Subsonic
import SwiftUI

struct QuestionsView: View {
  @Environment(GameViewModel.self) private var vm

  @AppStorage(AppStorageKey.duration.rawValue)
  private var duration = 30

  @State private var remaining = 0

  var onComplete: () -> Void = {}

  var body: some View {
    verticalContent
      .task {
        for await i in countdown(from: duration) {
          remaining = i
        }

        if remaining == 0 {
          vm.respond(false)
          onComplete()
        }
      }
  }

  var verticalContent: some View {
    VStack(spacing: 16) {
      Text(vm.currentQuestion.replaceEmphasized(with: .underline))
        .font(.title2)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
        .frame(height: 150)

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 8) {
          ForEach(vm.currentAnswers, id: \.self) { answer in
            HStack(alignment: .firstTextBaseline, spacing: 4) {
              AnswerRow(answer: answer, font: .title3)
            }
          }
        }
      }

      HStack {
        responseButton(true)
        responseButton(false)
      }

      countdownTimer
    }
  }

  @ViewBuilder
  private func responseButton(_ correct: Bool) -> some View {
    let title = correct ? "Correct" : "Incorrect"
    let tint = correct ? Color.correct : .incorrect
    let clip = "marimba_\(correct ? "positive" : "negative").mp3"

    WideButton(title: title) {
      vm.respond(correct)
      play(sound: clip)
    }
    .foregroundStyle(.primary)
    .fontWeight(.bold)
    .tint(tint)
  }

  @ViewBuilder
  private var countdownTimer: some View {
    let duration = Duration.seconds(remaining)
    let formatted = duration.formatted(.time(pattern: .minuteSecond))

    Text(formatted)
      .font(.title)
      .fontWeight(.bold)
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
