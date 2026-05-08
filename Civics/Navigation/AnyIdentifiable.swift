class AnyIdentifiable: Identifiable {
  public let destination: any Identifiable
  public init(destination: any Identifiable) {
    self.destination = destination
  }
}
