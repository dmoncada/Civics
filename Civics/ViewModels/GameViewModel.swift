import SwiftUI

@MainActor
@Observable
class GameViewModel {
  private(set) var questions: [CivicsQuestion]
  private(set) var responses = [(question: String, correct: Bool)]()

  private(set) var unionState: UnionState? = nil
  private(set) var senators: [Senator] = []
  private(set) var representatives: [Representative] = []

  private var currentIndex = 0

  init() {
    questions = CivicsDataLoader.load()
    reset()
  }

  func reset() {
    questions.shuffle()
    currentIndex = 0
    responses = []
  }

  func setState(_ state: UnionState) async throws {
    if unionState == state { return }

    let service = CongressService.shared
    async let task1 = service.fetchSenators(for: state)
    async let task2 = service.fetchRepresentatives(for: state)

    senators = try await task1
    representatives = try await task2
    unionState = state
  }

  func respond(_ correct: Bool) {
    responses.append((question, correct))
    advance()
  }

  private func advance() {
    currentIndex += 1

    if currentIndex == questions.count {
      questions.shuffle()
      currentIndex = 0
    }
  }

  var question: String {
    questions[currentIndex].question
  }

  var answers: [String] {
    let question = questions[currentIndex]

    switch question.id {
    case 23:  // State's senators.
      return senators.map(\.mediumName)
    case 29:  // State's representatives.
      return representatives.map(\.mediumName)
    case 61:  // State's governor.
      return ["Bob Ferguson"]
    case 62:  // State's capital.
      return [unionState?.capital ?? ""]
    default:
      return question.answers
    }
  }
}
