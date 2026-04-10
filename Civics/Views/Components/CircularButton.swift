import SwiftUI

struct CircularButton: View {
  let systemImage: String
  let action: () -> Void

  var size: CGFloat = 56
  var color: Color = .teal

  var body: some View {
    Button(action: action) {
      Image(systemName: systemImage)
        .font(.system(size: 24, weight: .bold))
        .foregroundColor(.white)
        .frame(width: size, height: size)
        .background(Circle().fill(color))
    }
  }
}

#Preview {
  CircularButton(systemImage: "gear") {
    print("You tapped me!")
  }
}
