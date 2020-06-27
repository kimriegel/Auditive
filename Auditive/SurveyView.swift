//// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

protocol MyEnum : CaseIterable, Equatable {
  var description : String { get }
}

protocol OrOtherP {

}

enum AgeRange : Int, MyEnum, Codable {
  case _17
  case _18_20
  case _21_29
  case _30_39
  case _40_49
  case _50_59
  case _60

  init(_ n : Int) {
    if n <= 17 { self = ._17 }
    else if n >= 18 && n <= 20 { self = ._18_20 }
    else if n >= 21 && n <= 29 { self = ._21_29 }
    else if n >= 30 && n <= 39 { self = ._30_39 }
    else if n >= 40 && n <= 49 { self = ._40_49 }
    else if n >= 50 && n <= 59 { self = ._50_59 }
    else { self = ._60 }
  }

  var description : String {
    switch(self) {
    case ._17: return "17 or younger"
    case ._18_20: return "18-20"
    case ._21_29: return "21-29"
    case ._30_39: return "30-39"
    case ._40_49: return "40-49"
    case ._50_59: return "50-59"
    case ._60: return "60 or older"
    }
  }

}

class OrOther<T : MyEnum> : Codable {
  static var unspecified : Self { let z = Self(); return z }
  var other : String?
  var choice : T?


  required init(from decoder: Decoder) throws {
    let values = try decoder.singleValueContainer()
    if let j = try? values.decode(Int.self) {
      if j == 0 {
        return
      } else {
        choice = T.allCases[ (j-1) as! T.AllCases.Index]
      }
    } else {
      if let k = try? values.decode(String.self) {
        other = k
      } else {
        fatalError("cannot get here?")
      }
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    if let o = other {
      try container.encode(o)
    } else if let c = choice {
      let j = T.allCases.firstIndex(where: {$0 == c} )
      try container.encode(j as! Int+1)
    } else {
      try container.encode(0)
    }
  }

  static func pick(_ z : Int) -> Self {
    if z == 0 {
      return Self()
    } else if z == T.allCases.count+1 {
      return Self(other: "")
    } else {
      return Self(choice: T.allCases[z-1 as! T.AllCases.Index])
    }
  }

  required init() {
    self.choice = nil
  }

  required init(other: String) {
    self.other = other
  }

  required init(choice: T) {
    self.choice = choice
  }

  static var allCases: [OrOther<T>] {
    return [Self()] + T.allCases.map { Self(choice: $0) } + [Self(other: "unspecified")]
  }

  var description: String {
    if let _ = other {
      return "Other (please specify)"
    } else if let t = choice {
      return t.description
    } else {
      return "Pick one"
    }
  }
}

enum Race : Int, MyEnum, Codable {
  case white
  case black
  case native
  case asian
  case islander
  case multi

  var description : String {
    switch(self) {
    case .white: return "White"
    case .black : return "Black or African-American"
    case .native: return "American Indian or Alaskan Native"
    case .asian: return "Asian"
    case .islander: return "Native Hawaiian or another Pacific islander"
    case .multi: return "Multi-Racial"
    }
  }
}

enum Gender : Int, MyEnum, Codable {
  case female
  case male

  var description: String {
    switch(self) {
    case .female: return "Female"
    case .male: return "Male"
    }
  }
}

enum Schooling : Int, MyEnum, Codable {
  case nohighschool
  case highschool
  case college
  case associate
  case bachelor
  case graduate

  var description : String {
    switch(self) {
    case .nohighschool: return "Less than high school degree"
    case .highschool: return "High school degree or equivalent (e.g., GED)"
    case .college: return "Some college but no degree"
    case .associate: return "Associate degree"
    case .bachelor: return "Bachelor degree"
    case .graduate: return "Graduate degree"
    }
  }
}


enum Employment : Int, MyEnum, Codable {
  case parttime
  case fulltime
  case looking
  case notlooking
  case retired
  case disabled

  var description : String {
    switch(self) {
    case .parttime: return "Employed, working 1-39 hours per week"
    case .fulltime: return "Employed, working 40 or more hours per week"
    case .looking: return "Not employed, looking for work"
    case .notlooking: return "Not employed, NOT looking for work"
    case .retired: return "Retired"
    case .disabled: return "Disabled, not able to work"
    }
  }
}

enum Residence : Int, MyEnum, Codable {
  case apartment
  case publichousing
  case townhome
  case detached

  var description: String {
    switch(self) {
    case .apartment: return "Apartment/Condominium"
    case .publichousing: return "Public Housing"
    case .townhome: return "Townhome"
    case .detached: return "Detached House"
    }
  }

  /*
   func encode(to encoder: Encoder) throws {
   var container = encoder.singleValueContainer()
   if let j = Self.allCases.firstIndex(where: {$0 == self} ) {
   try container.encode(j)
   } else {
   switch self {
   case .other(let e):
   try container.encode(e)
   default: fatalError("cannot get here")
   }
   }

   }

   init(from decoder: Decoder) throws {
   let values = try decoder.singleValueContainer()
   if let j = try? values.decode(Int.self) {
   self = Self.allCases[j]
   } else {
   if let k = try? values.decode(String.self) {
   self = Self.other(k)
   } else {
   fatalError("cannot get here?")
   }
   }

   }*/

}

class Health : Codable {
  var deafness : Bool = false
  var hypertension : Bool = false
  var heartRate : Bool = false
  var anxiety : Bool = false
  var learningProblems : Bool = false
  var sleeping : Bool = false
}


@propertyWrapper
struct Rating {
  var value : Int = 0

  init(wrappedValue: Int) {
    self.wrappedValue = wrappedValue
  }

  var wrappedValue : Int {
    get { value }
    set {
      let a = newValue
      let b : Int = min(a, 6)
      let c : Int = max(b, 0)
      value = c

    }
  }
}

class AffectedByNoise : Codable, ObservableObject {
  @Published var awakened : Int = 0
  @Published var studying: Int = 0
  @Published var usedTo : Int = 0
  @Published var music : Int = 0
  @Published var everyday : Int = 0
  @Published var concentrating : Int = 0
  @Published var library : Int = 0
  @Published var relax : Int = 0
  @Published var sensitive : Int = 0

  enum CodingKeys : String, CodingKey {
    case awakened
    case studying
    case usedTo
    case music
    case everyday
    case concentrating
    case library
    case relax
    case sensitive
  }

  required init() { }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    awakened = try values.decode(Int.self, forKey: .awakened)
    studying = try values.decode(Int.self, forKey: .studying)
    usedTo = try values.decode(Int.self, forKey: .usedTo)
    music = try values.decode(Int.self, forKey: .music)
    everyday = try values.decode(Int.self, forKey: .everyday)
    concentrating = try values.decode(Int.self, forKey: .concentrating)
    library = try values.decode(Int.self, forKey: .library)
    relax = try values.decode(Int.self, forKey: .relax)
    sensitive = try values.decode(Int.self, forKey: .sensitive)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(awakened, forKey: .awakened)
    try container.encode(studying, forKey: .studying)
    try container.encode(usedTo, forKey: .usedTo)
    try container.encode(music, forKey: .music)
    try container.encode(everyday, forKey: .everyday)
    try container.encode(concentrating, forKey: .concentrating)
    try container.encode(library, forKey: .library)
    try container.encode(relax, forKey: .relax)
    try container.encode(sensitive, forKey: .sensitive)
  }
}

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

struct EnumSegmentView<T : MyEnum > : View {
  let label : String
  @Binding var pick : OrOther<T>
  let allowOther : Bool

  //  @State var pickedOther : Bool = false
  @State var selection : Int = 0 // should initialize to initial value

  func setSelection() {
    if let _ = pick.other {
      self.selection = T.allCases.count+1
    } else if let c = self.pick.choice {
      self.selection = 1 + (T.allCases.firstIndex(of: c) as? Int ?? -1)
    } else {
      self.selection = 0
    }
  }

  var body : some View {
    setSelection()
    let c : Int = T.allCases.count+1+(allowOther ? 1 : 0)
    return HStack {
      Text(label).frame(width: 120)
      Picker(selection: Binding<Int>(get: { return self.selection },
                                     set: {
                                      self.pick = OrOther.pick($0)
                                      self.selection = $0
                                     } ),
             label: Text(label)) {
        ForEach(0..<c) {
          SplitOut<T>(x: $0)
        }
      }.pickerStyle(SegmentedPickerStyle())
      if self.pick.other != nil {
        TextField.init("Other", text: Binding(get: { self.pick.other ?? ""},
                                              set: { self.pick.other = $0 }))
      }
    }
  }
}


struct EnumWheelView<T : MyEnum> : View {
  let label : String
  @Binding var pick : OrOther<T>
  let allowOther : Bool

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
    return HStack {
      Spacer().layoutPriority(5)
      Picker(selection: Binding(get: {self.selection },
                                set: {
                                  self.pick = OrOther.pick($0)
                                  self.selection = $0
                                }),
             label: Text(label)
      ) {
        ForEach(0..<c) {
          SplitOut<T>(x:$0)
        }
      }.pickerStyle(WheelPickerStyle())
      .frame(width: 800)
      if self.pick.other != nil {
        TextField.init("Other", text: Binding(get: { self.pick.other ?? ""},
                                              set: { self.pick.other = $0 })).layoutPriority(5)
      }
      Spacer().layoutPriority(5)
    }
  }

}

class Survey : ObservableObject, Codable {
  var age = OrOther<AgeRange>()
  var race = OrOther<Race>()
  var gender = OrOther<Gender>()
  var schooling = OrOther<Schooling>()
  var employment = OrOther<Employment>()
  var residence = OrOther<Residence>()
  var health = Health()
  var affectedByNoise = AffectedByNoise()

}

struct HealthView : View {
  @Binding var health : Health

  var body : some View {
    Section(header: Text("Health Data")) {
      HStack {
        Toggle.init("Hearing Problems/Deafness", isOn: $health.deafness)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        Toggle.init("Hypertension", isOn: $health.hypertension)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        Toggle.init("Increased Heart Rate", isOn: $health.heartRate)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
      }

      HStack {
        Toggle.init("Anxiety", isOn: $health.anxiety)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        Toggle.init("Learning Problems", isOn: $health.learningProblems)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        Toggle.init("Trouble falling/staying asleep", isOn: $health.sleeping)
          .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
      }

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

 //   ScrollView.init(.vertical, showsIndicators: true) {
      Form {
        Section(header: Text("Demographic data")) {

          EnumSegmentView<AgeRange>(label: "Age", pick: self.$survey.age, allowOther: false)
          EnumSegmentView<Gender>(label: "Gender", pick: self.$survey.gender, allowOther: true)

          EnumWheelView<Race>(label: "Race", pick: self.$survey.race, allowOther: true)
          EnumWheelView<Schooling>(label: "Schooling", pick: self.$survey.schooling, allowOther: false)
          EnumWheelView<Employment>(label: "Employment", pick: self.$survey.employment, allowOther: false)

          EnumSegmentView<Residence>(label: "Residence", pick: self.$survey.residence, allowOther: true)
        }

           HealthView(health: $survey.health).padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20)).allowsTightening(true)

      AffectedByNoiseView(affectedByNoise: survey.affectedByNoise)

        Button(action: {
          saveSurvey(survey)
          self.needsRefresh = true
          print("Submit, \(self.survey)")
        }) {

          Text("Submit")
        }
//      }
    }.keyboardAdaptive()
  }
}

struct SurveyView_Previews: PreviewProvider {
  @State static var needsRefresh = false

  static var previews: some View {
    SurveyView(needsRefresh: $needsRefresh)
  }
}


