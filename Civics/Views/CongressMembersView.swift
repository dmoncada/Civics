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
              Text(member.mediumName)
            }
          }

          Section("Representatives") {
            ForEach(vm.representatives) { member in
              HStack {
                Text(member.mediumName)
                  .frame(alignment: .leading)

                if let district = member.district {
                  Spacer()
                  Text("District \(district)")
                    .frame(alignment: .trailing)
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

#Preview {
  CongressMembersView()
}
