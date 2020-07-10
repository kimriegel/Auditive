// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct HealthView : View {
  @Binding var health : Health

  var body : some View {
    Section(header: Text("Health Data")) {
//      HStack {
        Toggle.init("Hearing Problems/Deafness", isOn: $health.deafness)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        Toggle.init("Hypertension", isOn: $health.hypertension)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        Toggle.init("Increased Heart Rate", isOn: $health.heartRate)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
//      }

//      HStack {
        Toggle.init("Anxiety", isOn: $health.anxiety)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        Toggle.init("Learning Problems", isOn: $health.learningProblems)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        Toggle.init("Trouble falling/staying asleep", isOn: $health.sleeping)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
//      }

    }
  }
}


struct AffectedByNoiseView : View {
  @ObservedObject var affectedByNoise : AffectedByNoise

  var body: some View {
    Section(header: Text("Noise tolerance")) {
      RatingView(rating: $affectedByNoise.awakened, label: "I am easily awakened by noise",
                 maximumRating: 6)
      RatingView(rating: $affectedByNoise.studying, label: "If it's noisy where I'm studying, I try to close the door or window or move someplace else",
                 maximumRating: 6)
      RatingView(rating: $affectedByNoise.usedTo, label: "I get used to most noises without much difficulty",
                 maximumRating: 6)
      RatingView(rating: $affectedByNoise.music, label: "Even music I normally like will bother me if I'm trying to concentrate",
                 maximumRating: 6)


    }
  }
}


struct SurveyView : View {
  @State var survey = Survey()
  @Binding var needsRefresh : Bool
  
  var body : some View {
 //   let ps = WheelPickerStyle()

 //   ScrollView.init(.vertical, showsIndicators: true) {
    return // VStack {
      NavigationView {
        Form {
       Section(header: Text("Demographic data")) {

          EnumWheelView(label: "Age", pick: self.$survey.age, allowOther: false) // SegmentPickerStyle)(
          EnumWheelView(label: "Gender", pick: self.$survey.gender, allowOther: true) // false

          EnumWheelView(label: "Race", pick: self.$survey.race, allowOther: true)
          EnumWheelView(label: "Schooling", pick: self.$survey.schooling, allowOther: false)
          EnumWheelView(label: "Employment", pick: self.$survey.employment, allowOther: false)
          EnumWheelView(label: "Residence", pick: self.$survey.residence, allowOther: true ) // false
        }


      // Form {

           HealthView(health: $survey.health).padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20)).allowsTightening(true)

      AffectedByNoiseView(affectedByNoise: survey.affectedByNoise)

        Button(action: {
          saveSurvey(survey)
          self.needsRefresh = true
          print("Submit, \(self.survey)")
        }) {

          Text("Submit")
        }
        }.keyboardAdaptive()
      }.navigationBarTitle("Demographic")


 //   }
  }
}

struct SurveyView_Previews: PreviewProvider {
  @State static var needsRefresh = false

  static var previews: some View {
    SurveyView(needsRefresh: $needsRefresh)
  }
}


