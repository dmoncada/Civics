import SwiftUI

@MainActor
@Observable
class CongressMembersViewModel {
  var senators: [Senator] = []
  var representatives: [Representative] = []
  var isLoading = false

  func load(state: UnionState) async throws {
    defer { isLoading = false }
    isLoading = true

    let service = CongressService.shared
    async let task1 = service.fetchSenators(for: state)
    async let task2 = service.fetchRepresentatives(for: state)

    senators = try await task1.sorted {
      ($0.nameComponents.familyName ?? "")
        < ($1.nameComponents.familyName ?? "")
    }

    representatives = try await task2.sorted {
      ($0.district ?? 0)
        < ($1.district ?? 0)
    }

    var ids: [String] = []
    ids.append(contentsOf: senators.map(\.id))
    ids.append(contentsOf: representatives.map(\.id))

    let details = try await loadDetails(ids: ids)

    for i in senators.indices {
      senators[i].websiteUrl = details[senators[i].id]?.officialWebsiteUrl
    }
    for i in representatives.indices {
      representatives[i].websiteUrl = details[representatives[i].id]?.officialWebsiteUrl
    }
  }

  private func loadDetails(
    ids: [String],
    maxConcurrent: Int = 4
  ) async throws -> [String: CongressMemberDetail] {

    var iterator = ids.makeIterator()

    return try await withThrowingTaskGroup(
      of: (String, CongressMemberDetail).self
    ) { group in
      let service = CongressService.shared

      for _ in 0 ..< maxConcurrent {
        guard let id = iterator.next() else { break }

        group.addTask {
          let response = try await service.fetchMemberDetail(for: id)
          return (id, response.detail)
        }
      }

      var results: [String: CongressMemberDetail] = [:]

      while let (id, detail) = try await group.next() {
        results[id] = detail

        if let next = iterator.next() {
          group.addTask {
            let response = try await service.fetchMemberDetail(for: next)
            return (next, response.detail)
          }
        }
      }

      return results
    }
  }
}
