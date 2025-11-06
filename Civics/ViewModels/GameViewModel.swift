import Combine
import Foundation
import SwiftUI

enum GameState {
  case ready
  case inProgress
  case finished
}

class GameViewModel: ObservableObject {
  @Published var state: GameState = .ready
  @Published var allQuestions: [CivicsQuestion] = []
  @Published var currentQuestion: CivicsQuestion?
  @Published var correctCount = 0
  @Published var incorrectCount = 0
  @Published var timeRemaining = 60

  private var timer: Timer?

  func startGame(duration: Int) {
    allQuestions = CivicsDataLoader.load().shuffled()
    correctCount = 0
    incorrectCount = 0
    timeRemaining = duration
    state = .inProgress
    nextQuestion()
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      if self.timeRemaining > 0 {
        self.timeRemaining -= 1
      } else {
        self.endGame()
      }
    }
  }

  func nextQuestion() {
    guard !allQuestions.isEmpty else {
      endGame()
      return
    }
    currentQuestion = allQuestions.removeFirst()
  }

  func mark(correct: Bool) {
    if correct { correctCount += 1 } else { incorrectCount += 1 }
    nextQuestion()
  }

  func endGame() {
    timer?.invalidate()
    state = .finished
  }

  func resetGame() {
    state = .ready
  }
}
