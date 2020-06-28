//// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI


struct SplitOut<T:MyEnum> : View {
  let x : Int

  var body : some View {
    if x == 0 {
      return Text(OrOther<T>().description)
    }
    if x == T.allCases.count+1 {
      return Text(OrOther<T>(other: "").description)
    }
    if x > 0 && x < T.allCases.count + 1 {
      return Text(T.allCases[(x - 1) as! T.AllCases.Index].description)
    }
    return Text("cannot get here")
  }
}

struct EnumWheelView<T : MyEnum /*, U : PickerStyle */ > : View {
  let label : String
  @Binding var pick : OrOther<T>
  let allowOther : Bool
 // let style : U

  @State var selection : Int = 0

  func setSelection() {
    if let _ = pick.other {
      self.selection = T.allCases.count+1
    } else if let c = self.pick.choice {
      self.selection = 1 + (T.allCases.firstIndex(of: c) as? Int ?? -1)
    } else {
      self.selection = 0
    }
  }

  var body: some View {
    setSelection()

    let c : Int = T.allCases.count+1+(allowOther ? 1 : 0)
     // Form {
//        Section(header: Text(label) ) {
//      Spacer().layoutPriority(5)
      let p = Picker(selection: Binding(get: {self.selection },
                                set: {
                                  self.pick = OrOther.pick($0)
                                  self.selection = $0
                                }),
             label: Text(label)
      ) {
        ForEach(0..<c) {
          SplitOut<T>(x:$0)
        }
      }

    return p // .pickerStyle( style )
//      .frame(width: 800)

/*      if self.pick.other != nil {
        TextField.init("Other", text: Binding(get: { self.pick.other ?? ""},
                                              set: { self.pick.other = $0 }))
          // .layoutPriority(5)
      }
 */
//      Spacer().layoutPriority(5)
//    }.padding(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 30))
//  }
 }
}


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


