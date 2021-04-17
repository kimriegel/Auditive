// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct HealthView : View {
  @ObservedObject var health : Health
  @Binding var none : Bool

  var body : some View {
    Section(header: Text("Health Data")) {
      Toggle.init("Hearing Problems/Deafness", isOn: $health.deafness)
        .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
      Toggle.init("Hypertension", isOn: $health.hypertension)
        .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
      Toggle.init("Increased Heart Rate", isOn: $health.heartRate)
        .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))

      Toggle.init("Anxiety", isOn: $health.anxiety)
        .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
      Toggle.init("Learning Problems", isOn: $health.learningProblems)
        .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
      Toggle.init("Trouble falling/staying asleep", isOn: $health.sleeping)
        .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
      Toggle.init("None of the above", isOn: $none)
        .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }.onChange(of: none) { x in
      if x {
        health.clearAll()
      }
    }.onReceive(health.objectWillChange) {
      if health.anyTrue {
        none = false
      }
    }
  }
}

struct AffectedByNoiseView : View {
  @ObservedObject var affectedByNoise : AffectedByNoise
  let part : Int

  var body: some View {
    Section(header: Text("Noise tolerance (Part \(part == 1 ? "1" : "2"))")) {
      if part == 1 {
      Rater(rating: $affectedByNoise.awakened, label: "I am easily awakened by noise",
            maximumRating: 6)
      Rater(rating: $affectedByNoise.studying, label: "If it's noisy where I'm studying, I try to close the door or window or move someplace else",
            maximumRating: 6)
      Rater(rating: $affectedByNoise.usedTo, label: "I get used to most noises without much difficulty",
            maximumRating: 6)
      Rater(rating: $affectedByNoise.music, label: "Even music I normally like will bother me if I'm trying to concentrate",
            maximumRating: 6)
      Rater(rating: $affectedByNoise.everyday, label: "It wouldn't bother me to hear the sounds of everyday living from my neighbors (footsetps, running water, etc.)",
            maximumRating: 6)
      } else {
      Rater(rating: $affectedByNoise.concentrating, label: "I'm good at concentrating no matter what is going on around me",
            maximumRating: 6)
      Rater(rating: $affectedByNoise.library, label: "In a library, I don't mind if people carry on a conversation if they do it quietly",
            maximumRating: 6)
      Rater(rating: $affectedByNoise.relax, label: "I find it hard to relax in a place that's noisy",
            maximumRating: 6)
      Rater(rating: $affectedByNoise.sensitive, label: "I am sensitive to noise",
            maximumRating: 6)
      }

    }
  }
}

typealias XPick = MenuPick

struct SurveyView : View {
  @State var survey = Survey()
  @State var actualSelection : Int = 1
  @State var confirmedSelection : Int = 1
  @State var message : String = " "
  @State var healthProblem : Bool = false

  var body : some View {
    //   NavigationView {
    VStack {
      Text(message).foregroundColor(.red)
    TabView(selection: $actualSelection) {
      Form {
        Section(header: Text("Demographic data")) {
          XPick(label: "Age", pick: self.$survey.age, allowOther: false) // SegmentPickerStyle)(
          XPick(label: "Gender", pick: self.$survey.gender, allowOther: true) // false
          XPick(label: "Race", pick: self.$survey.race, allowOther: true)
          XPick(label: "Schooling", pick: self.$survey.schooling, allowOther: false)
          XPick(label: "Employment", pick: self.$survey.employment, allowOther: false)
          XPick(label: "Residence", pick: self.$survey.residence, allowOther: true ) // false
        }
      }.tag(1)

      Form {
        HealthView(health: survey.health, none: $healthProblem )
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20)).allowsTightening(true)
      }.tag(2)

      Form {
        AffectedByNoiseView(affectedByNoise: survey.affectedByNoise, part: 1)
      }.tag(3)

      Form {
        AffectedByNoiseView(affectedByNoise: survey.affectedByNoise, part: 2)
      }.tag(4)


      VStack {
        Text("Thank you for your participation")
        Button(action: {
          saveSurvey(self.survey)
          NotificationCenter.default.post(Notification(name: .savedSurvey))
        }) {

          Text("Submit")
        }
      }.tag(5)
    } // .keyboardAdaptive()
    .onChange(of: actualSelection) { x in
      if actualSelection == confirmedSelection { return }
      if (survey.section1Complete) && actualSelection < 3 {
        message = " "
        confirmedSelection = actualSelection
        return
      }
      if (survey.health.anyTrue || healthProblem ) && actualSelection < 4 {
        message = " "
        confirmedSelection = actualSelection
        return
      }
      if (survey.affectedByNoise.part1FilledOut) && actualSelection < 5 {
        message = " "
        confirmedSelection = actualSelection
        return
      }
      if (survey.affectedByNoise.part2FilledOut) && actualSelection < 6 {
        message = " "
        confirmedSelection = actualSelection
        return
      }
      actualSelection = confirmedSelection
      message = "Please complete this form before proceeding"
    }
    .padding(EdgeInsets.init(top: 0, leading: 15, bottom: 0, trailing: 15))
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    .tabViewStyle(PageTabViewStyle.init(indexDisplayMode: .always))

    }

    HStack {
      Button(action: {
        actualSelection -= 1
      }) {
        if actualSelection > 1 {
          Text("Back")
        } else {
          EmptyView()
        }
      }.frame(maxWidth:.infinity)

    Button(action: {
      actualSelection += 1
    }) {
      if actualSelection < 5 {
        Text("Next")
      } else {
      EmptyView()
      }
    }.frame(maxWidth:.infinity)
  }

  }
}

struct SurveyView_Previews: PreviewProvider {
  static var previews: some View {
    SurveyView()
  }
}
