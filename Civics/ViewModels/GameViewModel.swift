import SwiftUI

@MainActor
@Observable
class GameViewModel {
  static let maxQuestionsCount = 20
  static let minPassingCount = 12

  private(set) var responses = [(index: Int, correct: Bool)]()
  private(set) var correctCount = 0
  private(set) var incorrectCount = 0

  private(set) var unionState: UnionState? = nil
  private(set) var senators: [Senator] = []
  private(set) var representatives: [Representative] = []

  private var questions: [CivicsQuestion]
  private var questionIndices: [Int] = []
  private var currentIndex = 0

  var count: Int { questions.count }
  var isPassing: Bool { correctCount >= Self.minPassingCount }
  var isFailing: Bool { incorrectCount > Self.maxQuestionsCount - Self.minPassingCount }

  init() {
    guard let data = try? CivicsDataLoader.load() else { fatalError() }
    questions = data.sorted(using: KeyPathComparator(\.id))
    questionIndices = Array(0 ..< questions.count)
    reset()
  }

  func reset() {
    questionIndices.shuffle()
    currentIndex = 0

    responses = []
    correctCount = 0
    incorrectCount = 0
  }

  func setState(_ state: UnionState) async throws {
    if unionState == state { return }

    let service = CongressService.shared
    async let task1 = service.fetchSenators(for: state)
    async let task2 = service.fetchRepresentatives(for: state)

    let comparator1 = KeyPathComparator(\Senator.nameComponents.familyName)
    let comparator2 = KeyPathComparator(\Representative.district)

    senators = try await task1.sorted(using: comparator1)
    representatives = try await task2.sorted(using: comparator2)

    unionState = state
  }

  func respond(_ correct: Bool) {
    responses.append((questionIndex, correct))
    if correct {
      correctCount += 1
    } else {
      incorrectCount += 1
    }
    next()
  }

  private func next() {
    currentIndex += 1

    if currentIndex == questionIndices.count {
      questionIndices.shuffle()
      currentIndex = 0
    }
  }

  var currentQuestion: String {
    question(id: questionIndex)
  }

  var currentAnswers: [String] {
    answers(for: questionIndex)
  }

  func question(id index: Int) -> String {
    questions[index].question
  }

  func answers(for index: Int) -> [String] {
    let question = questions[index]

    switch question.id {
    case 23:  // State's senators.
      return senators.map(\.mediumName)
    case 29:  // State's representatives.
      return representatives.map(\.mediumName)
    case 30:  // Speaker.
      return ["Mike Johnson", "Johnson", "James Michael Johnson"]
    case 38:  // President.
      return ["Donald J. Trump", "Donald Trump", "Trump"]
    case 39:  // Vice president.
      return ["JD Vance", "Vance"]
    case 57:  // Chief justice.
      return ["John Roberts", "John G. Roberts, Jr.", "Roberts"]
    case 61:  // State's governor.
      return ["Bob Ferguson"]
    case 62:  // State's capital.
      return [unionState?.capital ?? ""]
    default:
      return question.answers
    }
  }

  private var questionIndex: Int { questionIndices[currentIndex] }
}
