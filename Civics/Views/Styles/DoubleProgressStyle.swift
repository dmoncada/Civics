import SwiftUI

struct DoubleProgressStyle: ProgressViewStyle {
  var secondaryFraction: Double

  func makeBody(configuration: Configuration) -> some View {
    let primary = configuration.fractionCompleted ?? 0
    let secondary = secondaryFraction

    return VStack(alignment: .center, spacing: 4) {
      GeometryReader { geometry in
        let width = geometry.size.width

        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .foregroundColor(.gray.opacity(0.25))

          let secondaryWidth = min(secondary * width, width)

          RoundedRectangle(cornerRadius: 8)
            .fill(Color.incorrect)
            .frame(width: secondaryWidth)
            .position(x: width - secondaryWidth / 2, y: 4)

          let primaryWidth = min(primary * width, width)

          RoundedRectangle(cornerRadius: 8)
            .fill(Color.correct)
            .frame(width: primaryWidth)
            .position(x: primaryWidth / 2, y: 4)

          Circle()
            .fill(Color.correct)
            .frame(width: 16, height: 16)
            .position(x: primaryWidth, y: 4)
        }
      }
      .frame(height: 8)

      configuration.label
        .font(.caption)
        .monospacedDigit()
        .foregroundColor(.secondary)
    }
  }
}
extension ProgressViewStyle where Self == DoubleProgressStyle {
  static func double(secondary: Double) -> DoubleProgressStyle {
    DoubleProgressStyle(secondaryFraction: secondary)
  }
}

#Preview {
  @Previewable @State var primary = 0
  @Previewable @State var secondary = 0

  let total = 20

  VStack(spacing: 16) {
    ProgressView(value: Double(primary), total: Double(total)) {
      Text("\(total - (primary + secondary)) questions left")
        .contentTransition(.numericText(countsDown: true))
    }
    .progressViewStyle(.double(secondary: Double(secondary) / Double(total)))

    HStack {
      Button("Add Primary") {
        withAnimation { primary += 1 }
      }

      Button("Add Secondary") {
        withAnimation { secondary += 1 }
      }
    }
  }
  .padding()
}
