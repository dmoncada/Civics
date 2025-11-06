import SwiftUI

struct GameView: View {
  @ObservedObject var vm: GameViewModel

  var body: some View {
    VStack(spacing: 30) {
      Text("Time: \(vm.timeRemaining)s")
        .font(.headline)

      if let question = vm.currentQuestion {
        Text(question.question)
          .font(.title2)
          .multilineTextAlignment(.center)
          .padding()

        VStack(alignment: .leading, spacing: 8) {
          ForEach(question.answers, id: \.self) { answer in
            Text("• \(answer)")
              .font(.body)
          }
        }
        .padding()
      } else {
        Text("Loading question...")
      }

      HStack(spacing: 40) {
        Button(action: { vm.mark(correct: false) }) {
          Label("Incorrect", systemImage: "xmark.circle.fill")
            .font(.title2)
            .foregroundColor(.red)
        }

        Button(action: { vm.mark(correct: true) }) {
          Label("Correct", systemImage: "checkmark.circle.fill")
            .font(.title2)
            .foregroundColor(.green)
        }
      }

      Spacer()
    }
    .padding()
  }
}
