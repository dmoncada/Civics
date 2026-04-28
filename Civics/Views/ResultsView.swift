import ConfettiSwiftUI
import SwiftUI

struct ResultsView: View {
  @Environment(GameViewModel.self) private var vm

  @State private var confetti = 0
  @State private var expanded = Set<Int>()

  var onCompleted: () -> Void = {}

  var body: some View {
    VStack(spacing: 16) {
      Text("You got ^[\(vm.correctCount) question](inflect: true) \(getIcon(vm.correctCount))")
        .font(.title2.bold())
        .confettiCannon(trigger: $confetti, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 180), radius: 200, repetitions: 3, repetitionInterval: 0.25)

      ScrollView(.vertical) {
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
          ForEach(vm.responses, id: \.index) { item in
            let (id, correct) = item
            let question = vm.question(id: id)
            let answers = vm.answers(for: id)

            // TODO: expanded question blends with answers; fix.
            Section(isExpanded: isExpanded(id)) {
              VStack(alignment: .leading, spacing: 8) {
                ForEach(answers, id: \.self) { answer in
                  AnswerRow(answer: answer, font: .system(size: 16))
                }
              }
              .padding(.vertical, 8)

            } header: {
              headerView(for: item)
            }
            .border(.blue)
          }
        }
        .padding()
      }
      .scrollBounceBehavior(.basedOnSize)
      .border(.red)

      WideButton(title: "Restart") {
        onCompleted()
      }
      .bold()
    }
    //    .onAppear {
    //      if vm.isPassing {
    //        play(clip: "ta_da_brass")
    //        confetti += 1
    //
    //      } else {
    //        play(clip: "marimba_shake")
    //      }
    //    }
  }

  private func getIcon(_ count: Int) -> String {
    let questionsCount = GameViewModel.maxQuestionsCount
    let passingCount = GameViewModel.minPassingCount

    switch count {
    case ..<passingCount:
      return "😔"
    case passingCount ..< questionsCount:
      return "💪"
    case questionsCount...:
      return "🎉"
    default:
      break
    }

    return "Unreachable"
  }

  private func isExpanded(_ id: Int) -> Binding<Bool> {
    Binding(
      get: { expanded.contains(id) },
      set: { new in
        if new {
          expanded.insert(id)
        } else {
          expanded.remove(id)
        }
      }
    )
  }

  @ViewBuilder
  private func headerView(for item: (Int, Bool)) -> some View {
    let (id, correct) = item
    let question = vm.question(id: id)
    let isExpanded = expanded.contains(id)

    HStack(alignment: .firstTextBaseline) {
      Text(question.replaceEmphasized(with: .underline))
        .font(.title3)
        .multilineTextAlignment(.leading)
        .foregroundColor(correct ? .primary : .secondary)

      Spacer()

      Image(systemName: "chevron.right")
        .rotationEffect(.degrees(isExpanded ? 90 : 0))
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(Rectangle())
    .padding(.vertical, 8)
    .onTapGesture {
      withAnimation {
        if expanded.remove(id) == nil {
          expanded.insert(id)
        }
      }
    }
  }
}

#Preview {
  let vm = GameViewModel()
  vm.respond(true)
  vm.respond(true)
  vm.respond(false)
  vm.respond(true)
  vm.respond(true)
  vm.respond(false)
  vm.respond(true)
  vm.respond(true)
  vm.respond(false)

  return ScreenContainer {
    ResultsView()
  }
  .environment(vm)
  .task {
    try? await vm.setState(.wa)
  }
}
