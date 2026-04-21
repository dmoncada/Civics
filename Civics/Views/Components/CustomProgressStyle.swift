import SwiftUI

struct CustomProgressStyle: ProgressViewStyle {
  func makeBody(configuration: Configuration) -> some View {
    let fraction = configuration.fractionCompleted ?? 0

    return VStack(alignment: .center, spacing: 4) {
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 8)
            .foregroundColor(.gray.opacity(0.25))

          RoundedRectangle(cornerRadius: 8)
            .fill(progressColor(for: fraction))
            .frame(width: min(fraction * geometry.size.width, geometry.size.width))
        }
      }
      .frame(height: 8)

      configuration.label
        .font(.caption)
        .monospacedDigit()
        .foregroundColor(.secondary)
    }
    .cornerRadius(8)
  }

  private func progressColor(for t: Double) -> Color {
    guard #available(iOS 18.0, *) else { return .accentColor }
    return Color.incorrect.mix(with: .correct, by: t, in: .perceptual)
  }
}

#Preview {
  @Previewable @State var count = 3

  let total = 20

  VStack(alignment: .leading, spacing: 8) {
    ProgressView(value: Double(count), total: Double(total)) {
      Text("\(count) of \(total)")
        .contentTransition(.numericText())
    }
    .progressViewStyle(CustomProgressStyle())

    Button("Add") {
      withAnimation {
        count += 1
      }
    }
  }
  .padding()
}
