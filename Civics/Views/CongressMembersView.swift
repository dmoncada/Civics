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
              memberCard(member)
            }
          }

          Section("Representatives") {
            ForEach(vm.representatives) { member in
              memberCard(member)
            }
          }
        }
      }
    }
    .task(id: state) {
      try? await vm.load(state: state)
    }
  }

  private func memberCard(_ member: CongressMember) -> some View {
    HStack {
      Avatar(imageUrl: member.imageUrl, initials: member.initials)

      VStack(alignment: .leading) {
        Text(member.mediumName)
          .bold()

        HStack(spacing: 4) {
          Text(member.party.name)
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

      HStack(spacing: 0) {
        let rawPhone = member.detail?.addressInformation.phoneNumber
        if let phone = extractPhone(rawPhone), let url = URL(string: "tel://\(phone)") {
          link(url, icon: "phone")
        }

        if let websiteUrl = member.detail?.officialWebsiteUrl, let url = URL(string: websiteUrl) {
          link(url, icon: "arrow.up.right.square")
        }
      }
    }
  }

  private func link(_ url: URL, icon: String) -> some View {
    Link(destination: url) {
      Image(systemName: icon)
        .foregroundStyle(Color.accentColor)
        .padding(4)
    }
    .buttonStyle(.plain)
  }

  private func extractPhone(_ input: String?) -> String? {
    guard let input else { return nil }
    let range = NSRange(location: 0, length: input.utf16.count)
    let result = NSTextCheckingResult.phoneNumberCheckingResult(range: range, phoneNumber: input)
    return result.phoneNumber?.filter { $0.isNumber }
  }
}

extension Party {
  fileprivate var style: some ShapeStyle {
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
