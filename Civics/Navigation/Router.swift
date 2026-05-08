import Observation
import SwiftUI

@Observable
final class Router {
  var path = NavigationPath()

  private var _sheetItem: AnyIdentifiable?
  var sheetItem: Binding<AnyIdentifiable?> {
    Binding(
      get: { self._sheetItem },
      set: { self._sheetItem = $0 }
    )
  }

  func showSheet(destination: any Identifiable) {
    _sheetItem = AnyIdentifiable(destination: destination)
  }

  func hideSheet() {
    _sheetItem = nil
  }

  func navigate(to destination: any Hashable) {
    path.append(destination)
  }

  func navigateBack() {
    path.removeLast()
  }

  func navigateToRoot() {
    path.removeLast(path.count)
  }
}
