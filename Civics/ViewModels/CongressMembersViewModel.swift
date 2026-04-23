import SwiftUI

@MainActor
@Observable
class CongressMembersViewModel {
  var senators: [Senator] = []
  var representatives: [Representative] = []
  var isLoading = false

  func load(state: UnionState) async {
    defer { isLoading = false }
    isLoading = true

    do {
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
    } catch {
      print(error)
    }
  }
}
