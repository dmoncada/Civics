import Foundation

@MainActor
final class CongressService {
  static let shared = CongressService()

  private let decoder = JSONDecoder()

  private var cache: [String: CacheEntry] = [:]

  private enum CacheEntry {
    case inProgress(Task<Data, Error>)
    case ready(Data)
  }

  func fetchMembers(for state: UnionState) async throws -> [CongressMember] {
    let url = try CongressApi.buildMembersUrl(for: state)
    let response: CongressResponse = try await fetch(url)

    return try response.members
      .map { member in
        CongressMember(
          id: member.bioguideId,
          type: member.isSenator ? .senator : .representative,
          party: try Party(validating: member.partyName),
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
