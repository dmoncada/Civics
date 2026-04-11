import Foundation

struct CivicsDataLoader {
  static func load() -> [CivicsQuestion] {
    guard let url = Bundle.main.url(forResource: "civics2025", withExtension: "json") else {
      print("File not found.")
      return []
    }

    do {
      let data = try Data(contentsOf: url)
      let decoded = try JSONDecoder().decode(CivicsData.self, from: data)
      let questions = decoded.sections.flatMap { $0.subsections.flatMap { $0.questions } }
      return questions.sorted { $0.id < $1.id }
    } catch {
      print("Failed to decode JSON: \(error)")
      return []
    }
  }
}
