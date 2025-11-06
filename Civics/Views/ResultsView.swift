import SwiftUI

struct ResultsView: View {
  let correct: Int
  let incorrect: Int
  let onDismiss: () -> Void  // Closure to notify parent

  var body: some View {
    VStack(spacing: 20) {
      Text("Results")
        .font(.largeTitle)

      Text("Correct: \(correct)")
      Text("Incorrect: \(incorrect)")

      Button("Back to Start") {
        onDismiss()  // Call closure
      }
      .padding()
      .font(.title2)
    }
    .padding()
    .frame(minWidth: 300, minHeight: 200)
  }
}
