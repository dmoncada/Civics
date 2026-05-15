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
