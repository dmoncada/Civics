import SwiftUI

@MainActor
@Observable
final class GameViewModel {
  static let maxQuestionsCount = 20
  static let minPassingCount = 12

  private(set) var responses = [(index: Int, correct: Bool)]()
  private(set) var correctCount = 0
  private(set) var incorrectCount = 0

  private(set) var unionState: UnionState? = nil
  private(set) var senators: [CongressMember] = []
  private(set) var representatives: [CongressMember] = []

  private var questions: [CivicsQuestion]
  private var questionIndices: [Int] = []
  private var currentIndex = 0

  private let favoritesKey = "favorite_ids"

  private(set) var favorites: Set<Int> = [] {
    didSet { saveFavorites() }
  }

  var count: Int { questions.count }
  var isPassing: Bool { correctCount >= Self.minPassingCount }
  var isFailing: Bool { incorrectCount > Self.maxQuestionsCount - Self.minPassingCount }
  var isFinished: Bool { responses.count >= Self.maxQuestionsCount }

  init() {
    guard let data = try? CivicsDataLoader.load() else { fatalError() }
    questions = data.sorted { $0.id < $1.id }
    questionIndices = Array(0 ..< questions.count)
    loadFavorites()
    reset()
  }

  func isFavorite(_ id: Int) -> Bool {
    favorites.contains(id)
  }

  func toggleFavorite(_ id: Int) {
    if favorites.remove(id) == nil {
      favorites.insert(id)
    }
  }

  private func saveFavorites() {
    let ids = Array(favorites)
    UserDefaults.standard.set(ids, forKey: favoritesKey)
  }

  private func loadFavorites() {
    let ids = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] ?? []
    favorites = Set(ids)
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
    let members = try await service.fetchMembers(for: state)

    senators =
      members
      .filter { $0.type == .senator }
      .sorted {
        ($0.nameComponents.familyName ?? "")
          < ($1.nameComponents.familyName ?? "")
      }

    representatives =
      members
      .filter { $0.type == .representative }
      .sorted {
        ($0.district ?? 0)
          < ($1.district ?? 0)
      }

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

extension GameViewModel {
  func favoriteBinding(for id: Int) -> Binding<Bool> {
    Binding(
      get: { self.isFavorite(id) },
      set: { newValue in
        if newValue {
          self.favorites.insert(id)
        } else {
          self.favorites.remove(id)
        }

        self.saveFavorites()
      }
    )
  }
}
