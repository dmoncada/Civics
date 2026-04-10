import SwiftUI

struct ResultsView: View {
  var vm: GameViewModel
  var onCompleted: () -> Void = {}

  var body: some View {
    ZStack {
      Color.purple.ignoresSafeArea()

      VStack(spacing: 30) {
        let correctCount = vm.responses.count(where: \.correct)
        Text("You got \(correctCount) questions!")
          .font(.largeTitle)
          .foregroundStyle(.white)
          .padding(.top)

        ScrollView(.vertical) {
          VStack(spacing: 16) {
            ForEach(vm.responses, id: \.question) { item in
              let (question, correct) = item
              Text(question)
                .font(.title2)
                .foregroundColor(correct ? .white : .white.opacity(0.5))
                .multilineTextAlignment(.center)
            }
          }
          .padding([.top, .bottom])
          .frame(maxWidth: .infinity)
        }
        .background(.blue.opacity(0.25))

        Button("Play again") {
          onCompleted()
        }
        .font(.title2)
        .bold()
        .background(.blue)
        .foregroundStyle(.white)
        .padding()
      }
    }
  }
}

#Preview {
  let vm = GameViewModel()

  vm.respond(true)
  vm.respond(true)
  vm.respond(false)

  return ResultsView(vm: vm)
}
