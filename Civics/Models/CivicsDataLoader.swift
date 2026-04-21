import Foundation

struct CivicsDataLoader {
  static func load() throws -> [CivicsQuestion] {
    let resource = "civics2025"
    guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
      fatalError("Resource: '\(resource).json' not found in main bundle.")
    }

    let data = try Data(contentsOf: url)
    let decoded = try JSONDecoder().decode(CivicsData.self, from: data)
    let questions = decoded.sections.flatMap { $0.subsections.flatMap { $0.questions } }
    return questions.sorted(using: KeyPathComparator(\.id))
  }
}
