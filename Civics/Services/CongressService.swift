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

  static func buildMembersUrl(
    for state: UnionState,
    limit: Int = 250,
    current: Bool = true
  ) throws -> URL {
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

  static func buildMemberDetailUrl(for id: String) throws -> URL {
    guard var components = URLComponents(string: baseUrl) else { throw URLError(.badURL) }

    components.path = "/v3/member/\(id)"
    components.queryItems = [
      URLQueryItem(name: "format", value: "json"),
      URLQueryItem(name: "api_key", value: apiKey),
    ]

    guard let url = components.url else { throw URLError(.badURL) }
    return url
  }
}

class CongressService {
  static let shared = CongressService()

  private let decoder = JSONDecoder()

  private var cache: [String: CacheEntry] = [:]

  private enum CacheEntry {
    case inProgress(Task<Data, Error>)
    case ready(Data)
  }

  func fetchSenators(for state: UnionState) async throws -> [Senator] {
    let url = try CongressApi.buildMembersUrl(for: state)
    let response: CongressResponse = try await fetch(url)

    return try response.members
      .filter(\.isSenator)
      .map { member in
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
    let url = try CongressApi.buildMembersUrl(for: state)
    let response: CongressResponse = try await fetch(url)

    return try response.members
      .filter(\.isRepresentative)
      .map { member in
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

  func fetchMemberDetail(for id: String) async throws -> CongressMemberDetailResponse {
    let url = try CongressApi.buildMemberDetailUrl(for: id)
    return try await fetch(url)
  }

  private func fetch<T: Decodable>(_ url: URL) async throws -> T {
    let data = try await fetchData(for: url)
    return try decoder.decode(T.self, from: data)
  }

  private func fetchData(for url: URL) async throws -> Data {
    let key = url.absoluteString

    if let cached = cache[key] {
      switch cached {
      case .inProgress(let task):
        return try await task.value

      case .ready(let data):
        return data
      }
    }

    let task = Task<Data, Error> {
      let (data, _) = try await URLSession.shared.data(from: url)
      return data
    }

    cache[key] = .inProgress(task)

    do {
      let data = try await task.value
      cache[key] = .ready(data)
      return data

    } catch {
      cache[key] = nil
      throw error
    }
  }

  private func getComponents(from name: String) throws -> PersonNameComponents {
    let (name, nickname) = try extractNickname(from: name)
    var components = try PersonNameComponents(name)
    components.nickname = nickname
    return components
  }
}
