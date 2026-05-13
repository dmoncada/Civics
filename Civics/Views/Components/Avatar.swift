import SwiftUI

struct Avatar: View {
  let imageUrl: String
  let initials: String
  let size: CGFloat

  init(
    imageUrl: String,
    initials: String,
    size: CGFloat = 32
  ) {
    self.imageUrl = imageUrl
    self.initials = initials
    self.size = size
  }

  var body: some View {
    AsyncImage(url: URL(string: imageUrl)) { phase in
      switch phase {

      case .empty:
        ProgressView()

      case .success(let image):
        image
          .resizable()
          .scaledToFill()

      default:
        ZStack {
          Circle()
            .fill(Color.gray.opacity(0.5))

          Text(initials)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundColor(.white)
        }
      }
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
  }
}
