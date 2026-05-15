import Foundation

enum Party: String {
  case democratic = "Democratic"
  case independent = "Independent"
  case libertarian = "Libertarian"
  case republican = "Republican"

  var name: String {
    self.rawValue.capitalized
  }
}

enum MemberType {
  case senator
  case representative
}

struct CongressResponse: Decodable {
  let members: [CongressMemberDto]
}

struct CongressMemberDto: Decodable {
  let bioguideId: String
  let depiction: Depiction
  let name: String
  let partyName: String
  let state: String
  let district: Int?
  let terms: Terms

  struct Depiction: Decodable {
    let imageUrl: String
  }

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

struct CongressMemberDetailResponse: Decodable {
  let detail: CongressMemberDetail

  enum CodingKeys: String, CodingKey {
    case detail = "member"
  }
}

struct CongressMemberDetail: Decodable {
  let addressInformation: AddressInformation
  let officialWebsiteUrl: String
}

struct AddressInformation: Codable {
  let city: String
  let officeAddress: String
  let phoneNumber: String
  let zipCode: Int
}

struct CongressMember: Identifiable {
  let id: String
  let type: MemberType
  let party: Party
  let state: UnionState
  let district: Int?
  let nameComponents: PersonNameComponents
  let imageUrl: String
  var detail: CongressMemberDetail?
}

extension CongressMember: NameFormattable {}
