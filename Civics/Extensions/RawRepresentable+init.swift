enum ValidationError: Error {
  case invalidInput(String)
}

extension RawRepresentable where RawValue == String {
  init(validating input: String) throws {
    guard let value = Self(rawValue: input) else {
      throw ValidationError.invalidInput("Invalid input: \(input)")
    }
    self = value
  }
}
