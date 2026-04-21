import SwiftUI

enum ReplacementStyle {
  case underline
  case strikethrough
}

extension String {
  func replaceEmphasized(with style: ReplacementStyle) -> AttributedString {
    guard var attributed = try? AttributedString(markdown: self) else {
      return AttributedString(self)
    }

    for run in attributed.runs where run.inlinePresentationIntent?.contains(.stronglyEmphasized) == true {
      switch style {
      case .underline:
        attributed[run.range].underlineStyle = .single
        break
      case .strikethrough:
        attributed[run.range].strikethroughStyle = .single
        break
      }
      attributed[run.range].inlinePresentationIntent = []
    }

    return attributed
  }
}
