import Foundation

// See: https://github.com/LibraryOfCongress/api.congress.gov
struct CongressApi {
  static let baseUrl = "https://api.congress.gov"

  static let apiKey: String = {
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
      print("API_KEY not found in Info.plist")
      return ""
    }
    return apiKey
  }()

  static func buildMembersUrl(for state: UnionState, limit: Int = 250, current: Bool = true) -> URL? {
    var components = URLComponents(string: baseUrl)
    components?.path = "/v3/member/\(state.rawValue)"
    components?.queryItems = [
      URLQueryItem(name: "format", value: "json"),
      URLQueryItem(name: "limit", value: limit.description),
      URLQueryItem(name: "currentMember", value: current.description),
      URLQueryItem(name: "api_key", value: apiKey),
    ]
    return components?.url
  }
}

class CongressService {
  static let shared = CongressService()

  func fetchMembers(for state: UnionState) async throws -> (senators: [Senator], representatives: [Representative]) {
    let response = try await fetchResponse(for: state)
    return parse(response: response)
  }

  private func fetchResponse(for state: UnionState) async throws -> CongressResponse {
    if let cached = cache[state] {
      switch cached {
      case .inProgress(let task):
        return try await task.value
      case .ready(let response):
        return response
      }
    }

    let task = Task {
      let url = CongressApi.buildMembersUrl(for: state)!
      let (data, _) = try await URLSession.shared.data(from: url)
      let response = try JSONDecoder().decode(CongressResponse.self, from: data)
      return response
    }

    cache[state] = .inProgress(task)

    do {
      let response = try await task.value
      cache[state] = .ready(response)
      return response
    } catch {
      cache[state] = nil
      throw error
    }
  }

  private func parse(response: CongressResponse) -> (senators: [Senator], representatives: [Representative]) {
    let senators = response.members.filter(\.isSenator).map { member in
      Senator(
        id: member.bioguideId,
        name: member.name,
        party: member.partyName,
        state: member.state
      )
    }

    var representatives = response.members.filter(\.isRepresentative).map { member in
      Representative(
        id: member.bioguideId,
        name: member.name,
        party: member.partyName,
        state: member.state,
        district: member.district
      )
    }

    representatives.sort {
      if let district1 = $0.district, let district2 = $1.district {
        return district1 < district2
      }

      return $0.name < $1.name
    }

    return (senators, representatives)
  }

  private var cache = [UnionState: CacheEntry]()

  private enum CacheEntry {
    case inProgress(Task<CongressResponse, Error>)
    case ready(CongressResponse)
  }
}
