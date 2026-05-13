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

                  Text(member.party.rawValue)
                    .font(.caption.weight(.light))
                    .foregroundStyle(member.party.style)
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

                  Text(member.party.rawValue)
                    .font(.caption.weight(.light))
                    .foregroundStyle(member.party.style)
                }

                if let district = member.district {
                  Spacer()
                  Text("District \(district)")

                    .font(.subheadline.weight(.light))
                }
              }
            }
          }
        }
      }
    }
    .task(id: state) {
      await vm.load(state: state)
    }
  }
}

extension Party {
  var style: some ShapeStyle {
    switch self {
    case .democratic:
      return .blue
    case .republican:
      return .red
    case .independent:
      return .green
    }
  }
}

#Preview {
  CongressMembersView()
}
