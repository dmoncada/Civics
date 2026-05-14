import SwiftUI

struct CongressMembersView: View {
  @State private var state: UnionState = .wa
  @State private var vm = CongressMembersViewModel()

  var body: some View {
    VStack {
      StatePicker(selected: $state)

      if vm.isLoading {
        Spacer()
        ProgressView()
        Spacer()

      } else {
        List {
          Section("Senators") {
            ForEach(vm.senators) { member in
              HStack {
                Avatar(imageUrl: member.imageUrl, initials: member.initials)

                VStack(alignment: .leading) {
                  Text(member.mediumName)
                    .bold()

                  Text(member.party.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(member.party.style)
                }

                Spacer()

                if let websiteUrl = member.websiteUrl, let url = URL(string: websiteUrl) {
                  websiteLink(url)
                }
              }
            }
          }

          Section("Representatives") {
            ForEach(vm.representatives) { member in
              HStack {
                Avatar(imageUrl: member.imageUrl, initials: member.initials)

                VStack(alignment: .leading) {
                  Text(member.mediumName)
                    .bold()

                  HStack(spacing: 4) {
                    Text(member.party.rawValue)
                      .font(.caption.bold())
                      .foregroundStyle(member.party.style)

                    if let district = member.district {
                      Text("·")
                      Text("District \(Text(String(district)).bold())")
                        .font(.caption.weight(.light))
                    }
                  }
                }

                Spacer()

                if let websiteUrl = member.websiteUrl, let url = URL(string: websiteUrl) {
                  websiteLink(url)
                }
              }
            }
          }
        }
      }
    }
    .task(id: state) {
      try? await vm.load(state: state)
    }
  }

  private func websiteLink(_ url: URL) -> some View {
    Link(destination: url) {
      Image(systemName: "arrow.up.right.square")
        .foregroundStyle(Color.accentColor)
        .padding(4)
    }
    .buttonStyle(.plain)
  }
}

extension Party {
  var style: some ShapeStyle {
    switch self {
    case .democratic:
      return .blue
    case .independent, .libertarian:
      return .green
    case .republican:
      return .red
    }
  }
}

#Preview {
  CongressMembersView()
}
