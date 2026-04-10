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

      senators = try await task1
      representatives = try await task2

    } catch {
      print(error)
    }
  }
}
