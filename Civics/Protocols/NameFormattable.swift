import Foundation

protocol NameFormattable {
  var nameComponents: PersonNameComponents { get }
}

extension NameFormattable {
  var initials: String { nameComponents.formatted(.name(style: .abbreviated)) }
  var shortName: String { nameComponents.formatted(.name(style: .short)) }
  var mediumName: String { nameComponents.formatted(.name(style: .medium)) }
  var longName: String { nameComponents.formatted(.name(style: .long)) }
}
