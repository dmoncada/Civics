import Foundation

struct CongressResponse: Decodable {
  let members: [CongressMember]
}

struct CongressMember: Decodable {
  let bioguideId: String
  let name: String
  let partyName: String
  let state: String
  let district: Int?
  let terms: Terms

  struct Terms: Decodable {
    let item: [Term]
  }

  struct Term: Decodable {
    let chamber: String
    let startYear: Int
    let endYear: Int?
  }

  var isSenator: Bool {
    terms.item.contains { $0.chamber == "Senate" && $0.endYear == nil }
  }

  var isRepresentative: Bool {
    terms.item.contains { $0.chamber == "House of Representatives" && $0.endYear == nil }
  }
}

struct Senator: Identifiable {
  let id: String
  let party: String
  let state: UnionState
  let nameComponents: PersonNameComponents
}

struct Representative: Identifiable {
  let id: String
  let party: String
  let state: UnionState
  let district: Int?
  let nameComponents: PersonNameComponents
}

extension Senator: NameFormattable {}
extension Representative: NameFormattable {}
