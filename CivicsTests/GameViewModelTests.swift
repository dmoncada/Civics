import Testing

@testable import Civics

@MainActor
struct CivicsTests {
  @Test
  func testCount() {
    let vm = GameViewModel()
    #expect(vm.count == 128)
  }

  @Test
  func testResponses() {
    let vm = GameViewModel()
    let values = [true, false, true, false]

    for x in values {
      vm.respond(x)
    }

    #expect(values.count == vm.responses.count)

    for (expected, (_, actual)) in zip(values, vm.responses) {
      #expect(expected == actual)
    }
  }

  @Test
  func testWrapAround() {
    let vm = GameViewModel()
    let count = vm.count

    for _ in 0 ... count {  // Respond n+1 times.
      vm.respond(true)
    }

    #expect(count + 1 == vm.responses.count)

    let all = Set(vm.responses.map(\.index).map { vm.question(id: $0) })

    #expect(count == all.count)
  }

  @Test
  func testPassing() {
    let vm = GameViewModel()
    let passingCount = GameViewModel.minPassingCount

    for _ in 1 ..< passingCount {
      vm.respond(true)
    }

    #expect(vm.isPassing == false)

    vm.respond(true)

    #expect(vm.isPassing)
  }
}
