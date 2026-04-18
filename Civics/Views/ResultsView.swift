import SwiftUI

struct ResultsView: View {
  @Environment(GameViewModel.self) private var vm

  var onCompleted: () -> Void = {}

  var body: some View {
    VStack(spacing: 16) {
      let correctCount = vm.responses.count(where: \.correct)
      Text("You got \(correctCount) questions!")
        .font(.title2)
        .fontWeight(.bold)

      ScrollView(.vertical) {
        VStack(spacing: 16) {
          ForEach(vm.responses, id: \.question) { item in
            let (question, correct) = item
            Text(question)
              .font(.title3)
              .foregroundColor(correct ? .primary : .secondary)
              .multilineTextAlignment(.center)
          }
        }
        .frame(maxWidth: .infinity)
        .padding()
      }
      .background(.white.opacity(0.25))

      WideButton(title: "Play again") {
        onCompleted()
      }
      .fontWeight(.bold)
    }
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
}
