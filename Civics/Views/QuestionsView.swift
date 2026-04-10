import SwiftUI

struct QuestionsView: View {
  @AppStorage(AppStorageKey.duration.rawValue)
  private var duration = 30

  @State private var remaining = 0

  var vm: GameViewModel
  var onComplete: () -> Void = {}

  var body: some View {
    ZStack {
      Color.green.ignoresSafeArea()

      VStack {
        Text(vm.question)
          .font(.title)

        VStack {
          ForEach(vm.answers, id: \.self) { answer in
            Text("- \(answer)")
          }
        }

        HStack {
          Button {
            vm.respond(true)
          } label: {
            Text("Correct")
              .font(.headline)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.yellow)
              .cornerRadius(12)
          }

          Button {
            vm.respond(false)
          } label: {
            Text("Incorrect")
              .font(.headline)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.red)
              .cornerRadius(12)
          }
        }

        let duration = Duration.seconds(remaining)
        Text(duration.formatted(.time(pattern: .minuteSecond)))
          .font(.title)

        Button("See Results") {
          onComplete()
        }
        .font(.title)
        .foregroundStyle(.white)
      }
    }
    .task {
      for await i in countdown(from: duration) {
        remaining = i
      }

      if remaining == 0 {
        onComplete()
      }
    }
  }
}

#Preview {
  return QuestionsView(vm: GameViewModel()) {
    print("Elapsed")
  }
}
