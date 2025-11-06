import SwiftUI

struct ContentView: View {
  @StateObject private var vm = GameViewModel()
  @State private var selectedDuration = 60

  var body: some View {
    VStack {
      switch vm.state {
      case .ready:
        TimerPickerView(selectedDuration: $selectedDuration)
        Button("Start Game") {
          vm.startGame(duration: selectedDuration)
        }
        .padding()
        .font(.title2)

      case .inProgress:
        GameView(vm: vm)

      case .finished:
        GameView(vm: vm)
          .sheet(
            isPresented: Binding(
              get: { vm.state == .finished },
              set: { _ in vm.resetGame() }
            )
          ) {
            ResultsView(
              correct: vm.correctCount,
              incorrect: vm.incorrectCount,
              onDismiss: {
                vm.resetGame()  // Return to main screen
              }
            )
          }
      }
    }
    .frame(minWidth: 400, minHeight: 500)
  }
}
