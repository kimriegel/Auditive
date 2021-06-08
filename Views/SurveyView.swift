// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI


typealias XPick = MenuPick

struct SurveyView : View {
  // @ObservedObject
  @CodableStorage(Key.healthSurvey) var survey = Survey()
  @State var actualSelection : Int = 1
  @State var confirmedSelection : Int = 1
  @State var message : String = " "
  @State var healthProblem : Bool = false

  @State var uuid : UUID = UUID()

  let maxTab = 7

  var body : some View {
    //   NavigationView {

    VStack {
      ZStack {
      Text(uuid.uuidString).hidden()
        VStack {
      Text(message).foregroundColor(.red)
      TabView(selection: $actualSelection) {
        Form {
          Section(header: Text("Demographics")) {
            XPick(label: "Age", pick: self.$survey.age, allowOther: false) // SegmentPickerStyle)(
            XPick(label: "Gender", pick: self.$survey.gender, allowOther: true) // false
            XPick(label: "Ethnic background", pick: self.$survey.ethnic, allowOther: true)
          /*  XPick(label: "Schooling", pick: self.$survey.schooling, allowOther: false)
             */
            XPick(label: "Employment", pick: self.$survey.employment, allowOther: false)
            XPick(label: "Income", pick: self.$survey.income, allowOther: false ) // false
          }
        }.tag(1)

        Form {
          Section(header: Text("Medical(1)")) {

            HealthView(health: $survey.health /*, none: $healthProblem */ )
              // .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
              .allowsTightening(true)
          }
        }.tag(2)

        Form {
          Section(header: Text("Medical(2)")) {

            HealthView2(health: $survey.health /*, none: $healthProblem */ )
              // .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
              .allowsTightening(true)
          }
        }.tag(3)



        NoiseView(noise: $survey.noise, part: 1)
        .tag(4)

        NoiseView(noise: $survey.noise, part: 2)
          .tag(5)

/*        Form {
          Section(header: Text("Work Environment")) {
            Text("Work Environment")
//          AffectedByNoiseView(affectedByNoise: survey.affectedByNoise, part: 1)
          }
        }.tag(5)
*/

            PerceptionView(noise: $survey.noise)
//          AffectedByNoiseView(affectedByNoise: survey.affectedByNoise, part: 2)
        .tag(6)


        VStack {
          Text("Thank you for your participation")
          Button(action: {
            saveSurvey(self.survey)
          }) {

            Text("Submit")
          }
        }.tag(maxTab)
      }
    }
      }// .keyboardAdaptive()
      .onReceive(survey.objectWillChange) {
        uuid = UUID()
      }
      .onChange(of: actualSelection) { x in
        if actualSelection == confirmedSelection { return }
        if (survey.section1Complete) && actualSelection < 3 {
          message = " "
          confirmedSelection = actualSelection
          return
        }
        if actualSelection == 3 {
          message = " "
          confirmedSelection = actualSelection
          return
        }
        if survey.health.complete && actualSelection == 4 {
          message = " "
          confirmedSelection = actualSelection
          return
        }
        if survey.noise.homeNoise.complete && actualSelection == 5 {
          message = " "
          confirmedSelection = actualSelection
          return
        }

        if survey.noise.workNoise.complete && actualSelection == 6 {
          message = " "
          confirmedSelection = actualSelection
          return
        }

        if survey.noise.perceptionNoise.complete && actualSelection == 7 {
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

    .onReceive(survey.objectWillChange) {_ in
      // do I do anything here?
    }
/*    .onChange(of: survey) { _ in
      print("xupdate")
    }*/

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
        if actualSelection < maxTab {
          Text("Next")
        } else {
          EmptyView()
        }
      }.frame(maxWidth:.infinity)
    }
    }
  }
}

struct SurveyView_Previews: PreviewProvider {
  static var previews: some View {
    SurveyView()
  }
}
