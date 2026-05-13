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

  static func buildMembersUrl(for state: UnionState, limit: Int = 250, current: Bool = true) throws -> URL {
    guard var components = URLComponents(string: baseUrl) else { throw URLError(.badURL) }

    components.path = "/v3/member/\(state.code)"
    components.queryItems = [
      URLQueryItem(name: "format", value: "json"),
      URLQueryItem(name: "limit", value: limit.description),
      URLQueryItem(name: "currentMember", value: current.description),
      URLQueryItem(name: "api_key", value: apiKey),
    ]

    guard let url = components.url else { throw URLError(.badURL) }
    return url
  }
}

class CongressService {
  static let shared = CongressService()

  func fetchSenators(for state: UnionState) async throws -> [Senator] {
    let response = try await fetchResponse(for: state)

    return try response.members.filter(\.isSenator).map { member in
      Senator(
        id: member.bioguideId,
        party: Party(rawValue: member.partyName)!,
        state: try UnionState(validating: member.state),
        nameComponents: try getComponents(from: member.name),
        imageUrl: member.depiction.imageUrl
      )
    }
  }

  func fetchRepresentatives(for state: UnionState) async throws -> [Representative] {
    let response = try await fetchResponse(for: state)

    return try response.members.filter(\.isRepresentative).map { member in
      Representative(
        id: member.bioguideId,
        party: Party(rawValue: member.partyName)!,
        state: try UnionState(validating: member.state),
        district: member.district,
        nameComponents: try getComponents(from: member.name),
        imageUrl: member.depiction.imageUrl
      )
    }
  }

  private func getComponents(from name: String) throws -> PersonNameComponents {
    let (name, nickname) = try extractNickname(from: name)
    var components = try PersonNameComponents(name)
    components.nickname = nickname
    return components
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
      let url = try CongressApi.buildMembersUrl(for: state)
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

  private var cache = [UnionState: CacheEntry]()

  private enum CacheEntry {
    case inProgress(Task<CongressResponse, Error>)
    case ready(CongressResponse)
  }
}
