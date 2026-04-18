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
          onComplete()
        }
      }
  }

  var verticalContent: some View {
    VStack(spacing: 16) {
      Text(vm.question)
        .font(.title2)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .frame(height: 150)
      //        .border(.red)

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 8) {
          ForEach(vm.answers, id: \.self) { answer in
            HStack(alignment: .firstTextBaseline, spacing: 4) {
              Text("🇺🇸")
                .font(.title3)
                .scaleEffect(0.75)

              Text(answer)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
      }

      HStack {
        WideButton(title: "Correct") {
          respond(true)
        }
        .foregroundStyle(.primary)
        .fontWeight(.bold)
        .tint(.correct)

        WideButton(title: "Incorrect") {
          respond(false)
        }
        .foregroundStyle(.primary)
        .fontWeight(.bold)
        .tint(.incorrect)
      }

      let duration = Duration.seconds(remaining)
      let formatted = duration.formatted(.time(pattern: .minuteSecond))
      Text(formatted)
        .font(.title)
        .fontWeight(.bold)
        .monospacedDigit()
    }
  }

  private func respond(_ correct: Bool) {
    let clip = "marimba_\(correct ? "positive" : "negative").mp3"
    vm.respond(correct)
    play(sound: clip)
  }
}

#Preview {
  ScreenContainer {
    QuestionsView()
  }
  .environment(GameViewModel())
}
