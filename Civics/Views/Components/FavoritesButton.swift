import SwiftUI

struct FavoriteButton: View {
  @Binding var isSet: Bool

  var body: some View {
    Button(action: {
      isSet.toggle()
    }) {
      Image(systemName: isSet ? "star.fill" : "star")
        .foregroundStyle(isSet ? Color.yellow : .gray)
    }
  }
}
