import SwiftUI

@MainActor
@Observable
class CongressMembersViewModel {
  var senators: [Senator] = []
  var representatives: [Representative] = []
  var isLoading = false

  func load(state: UnionState) async {
    do {
      defer { isLoading = false }
      isLoading = true

      let service = CongressService.shared
      let (senators, representatives) = try await service.fetchMembers(for: state)

      self.senators = senators
      self.representatives = representatives

    } catch {
      print(error)
    }
  }
}
