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

      let comparator1 = KeyPathComparator(\Senator.nameComponents.familyName)
      let comparator2 = KeyPathComparator(\Representative.district)

      senators = try await task1.sorted(using: comparator1)
      representatives = try await task2.sorted(using: comparator2)

    } catch {
      print(error)
    }
  }
}
