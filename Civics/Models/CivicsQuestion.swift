import Foundation

struct CivicsData: Codable {
  let sections: [CivicsSection]
}

struct CivicsSection: Codable {
  let name: String
  let subsections: [CivicsSubsection]
}

struct CivicsSubsection: Codable {
  let id: String
  let name: String
  let questions: [CivicsQuestion]
}

struct CivicsQuestion: Codable, Identifiable {
  let id: Int
  let question: String
  let answers: [String]
}
