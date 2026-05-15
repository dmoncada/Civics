import SwiftUI

@MainActor
@Observable
class CongressMembersViewModel {
  var senators: [CongressMember] = []
  var representatives: [CongressMember] = []
  var isLoading = false

  func load(state: UnionState) async throws {
    defer { isLoading = false }
    isLoading = true

    let service = CongressService.shared
    var members = try await service.fetchMembers(for: state)

    let ids = members.map { $0.id }
    let details = try await loadDetails(ids: ids)

    for index in members.indices {
      members[index].detail = details[members[index].id]
    }

    senators =
      members
      .filter { $0.type == .senator }
      .sorted {
        ($0.nameComponents.familyName ?? "")
          < ($1.nameComponents.familyName ?? "")
      }

    representatives =
      members
      .filter { $0.type == .representative }
      .sorted {
        ($0.district ?? 0)
          < ($1.district ?? 0)
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
