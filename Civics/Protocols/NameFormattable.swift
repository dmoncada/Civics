import Foundation

protocol NameFormattable {
  var name: String { get }
}

extension NameFormattable {
  private func formattedName(style: PersonNameComponentsFormatter.Style) -> String {
    let formatter = PersonNameComponentsFormatter()
    formatter.style = style

    if let components = formatter.personNameComponents(from: name) {
      return formatter.string(from: components)
    }

    return name
  }

  var shortName: String { formattedName(style: .short) }
  var mediumName: String { formattedName(style: .medium) }
  var longName: String { formattedName(style: .long) }
}
