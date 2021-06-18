// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import Combine
protocol MyEnum : CaseIterable, Equatable {
  var description : String { get }
}

struct HealthCondition : Codable, Equatable, Booler {
  var label : String
  var bools : [Bool]

  init(_ label : String) {
    self.label = label
    bools = [false, false]
  }

  static var labels = ["Conditions", "You", "Fam"]
}

struct HealthSymptom : Codable, Equatable, Booler {
  var label : String
  var bools : [Bool]
  static var labels = ["Symptoms", ""]
  
  init(_ label : String) {
    self.label = label
    bools = [false]
  }
}

enum Oftenness : Int, MyEnum, Codable {
  case never
  case monthly
  case weekly
  case daily

  var description : String {
    switch(self) {
    case .never: return "Never"
    case .monthly: return "Monthly"
    case .weekly: return "Weekly"
    case .daily: return "Daily"
    }
  }
}

enum AgeRange : Int, MyEnum, Codable {
  case _18_24
  case _25_34
  case _35_44
  case _45_54
  case _55_64
  case _65_74
  case _75

  /*
   init(_ n : Int) {
   if n >= 18 && n <= 24 { self = ._18_24 }
   else if n >= 25 && n <= 34 { self = ._25_34}
   else if n >= 35 && n <= 44 { self = ._35_44 }
   else if n >= 45 && n <= 54 { self = ._45_54 }
   else if n >= 55 && n <= 64 { self = ._55_64 }
   else if n >= 65 && n <= 74 { self = ._65_74 }
   else { self = ._75 }
   }*/
  
  var description : String {
    switch(self) {
    case ._18_24: return "18-24"
    case ._25_34: return "25-34"
    case ._35_44: return "35-44"
    case ._45_54: return "45-54"
    case ._55_64: return "55-64"
    case ._65_74: return "65-74"
    case ._75: return "75 or older"
    }
  }
}

enum Income : Int, MyEnum, Codable {
  case _10
  case _10_20
  case _20_30
  case _30_40
  case _40_50
  case _50_60
  case _60_70
  case _70_80
  case _80_90
  case _90_100
  case _100_150
  case _150

  /*
   init(_ n : Int) {
   if n >= 18 && n <= 24 { self = ._18_24 }
   else if n >= 25 && n <= 34 { self = ._25_34}
   else if n >= 35 && n <= 44 { self = ._35_44 }
   else if n >= 45 && n <= 54 { self = ._45_54 }
   else if n >= 55 && n <= 64 { self = ._55_64 }
   else if n >= 65 && n <= 74 { self = ._65_74 }
   else { self = ._75 }
   }*/

  var description : String {
    switch(self) {
    case ._10: return "Less than $10,000"
    case ._10_20: return "$10,000 to $19,999"
    case ._20_30: return "$20,000 to $29,999"
    case ._30_40: return "$30,000 to $39,999"
    case ._40_50: return "$40,000 to $49,999"
    case ._50_60: return "$50,000 to $59,999"
    case ._60_70: return "$60,000 to $69,999"
    case ._70_80: return "$70,000 to $79,999"
    case ._80_90: return "$80,000 to $89,999"
    case ._90_100: return "$90,000 to $99,999"
    case ._100_150: return "$100,000 to $149,999"
    case ._150: return "$150,000 or more"
    }
  }
}

struct OrOther<T : MyEnum> : Codable, Equatable {
  static var unspecified : Self { let z = Self(); return z }
  var other : String?
  var choice : T?

  var choiceIndex : Int { get {
    if let c = choice {
      return T.allCases.firstIndex(of: c) as? Int ?? -1
    } else {
      return -1
    }
  }}

  var complete : Bool { get {
    return choice != nil || ( other != nil && !other!.isEmpty )
  }}
  
  init(from decoder: Decoder) throws {
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
  
  init() {
    self.choice = nil
  }
  
  init(other: String) {
    self.other = other
  }
  
  init(choice: T) {
    self.choice = choice
  }
  
  static var allCases: [OrOther<T>] {
    return [Self()] + T.allCases.map { Self(choice: $0) } + [Self(other: "unspecified")]
  }
  
  var description: String {
    if let _ = other {
      return "Other"
    } else if let t = choice {
      return t.description
    } else {
      return "Pick one"
    }
  }
}

enum EthnicBackground : Int, MyEnum, Codable {
  case white
  case latino
  case black
  case native
  case asian
  case none
  
  var description : String {
    switch(self) {
    case .white: return "White"
    case .latino : return "Hispanic or Latino"
    case .black : return "Black or African American"
    case .native: return "Native American or American Indian"
    case .asian: return "Asian / Pacific Islander"
    case .none: return "I prefer not to answer"
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

enum Employment : Int, MyEnum, Codable {
  case wages
  case selfe
  case looking
  case notlooking
  case homemaker
  case student
  case military
  case retired
  case disabled
  
  var description : String {
    switch(self) {
    case .wages: return "Employed for wages"
    case .selfe: return "Self-employed"
    case .looking: return "Out of work and looking for work"
    case .notlooking: return "Out of work but not currently looking for work"
    case .homemaker: return "A homemaker"
    case .student: return "A student"
    case .military: return "Military"
    case .retired: return "Retired"
    case .disabled: return "Unable to work"
    }
  }
}

struct Health : Codable, Equatable {

  var conditions = ["Heart diseases", "Diabetes", "Dementia", "Stroke", "Migraine", "Thyroid", "Hyperactivity/ADD", "Substance Use Disorder", "Sleep Disorder", "Depression", "Bipolar Disorder"].map{ HealthCondition($0) }
  var symptoms = ["Seizures", "Shakiness", "Sweats (night)", "Nosebleeds", "Lightheadedness", "Dizziness", "Hearing loss", "Loss of Consciousness", "Confusion", "Panic Attacks"].map { HealthSymptom($0) }


  var smoking = OrOther<Oftenness>()
  var drinking = OrOther<Oftenness>()

  var complete : Bool { get {
    return smoking.complete && drinking.complete
  }}

  init() {
  }
}

enum Occasionality : Int, MyEnum, Codable {
  case never
  case sometimes
  case always

  var description : String {
    switch(self) {
    case .never: return "Never"
    case .sometimes: return "Sometimes"
    case .always: return "Always"
    }
  }
}

enum OftennessX : Int, MyEnum, Codable {
  case never
  case fewMonths
  case monthly
  case weekly
  case daily

  var description : String {
    switch(self) {
    case .never: return "Never"
    case .fewMonths: return "Every few months"
    case .monthly: return "Monthly"
    case .weekly: return "Weekly"
    case .daily: return "Daily"
    }
  }
}

enum Frequentness : Int, MyEnum, Codable {
  case never
  case hours_1
  case hours_1_3
  case hours_4_6
  case hours_8

  var description : String {
    switch(self) {
    case .never: return "Never"
    case .hours_1: return "< 1 hour"
    case .hours_1_3: return "1-3 hours"
    case .hours_4_6: return "4-7 hours"
    case .hours_8: return "8+ hours"
    }
  }
}





enum OneToFive : Int, MyEnum, Codable {
  case one
  case two
  case three
  case four
  case five

  var description : String {
    switch(self) {
    case .one: return "1"
    case .two: return "2"
    case .three: return "3"
    case .four: return "4"
    case .five: return "5"
    }
  }
}

enum Living : Int, MyEnum, Codable {
  case lessThanOneYear
  case twoYears
  case fiveYears
  case moreThanTenYears

  var description : String {
    switch(self) {
    case .lessThanOneYear: return "< 1 year"
    case .twoYears: return "2 years"
    case .fiveYears: return "5 years"
    case .moreThanTenYears: return "10+ years"
    }
  }
}

struct WorkNoise : Codable, Equatable {
  var noisy : Int = 0
  var earPlugs = OrOther<Occasionality>()
  var vehicles = OrOther<Oftenness>()

  enum CodingKeys : String, CodingKey {
    case noisy
    case earPlugs
    case vehicles
  }

  var complete : Bool { get {
    return noisy != 0 && earPlugs.complete && vehicles.complete
  }}

  init() {
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    noisy = try values.decode(Int.self, forKey: .noisy)
    earPlugs = try values.decode(OrOther<Occasionality>.self, forKey: .earPlugs)
    vehicles = try values.decode(OrOther<Oftenness>.self, forKey: .vehicles)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(noisy, forKey: .noisy)
    try container.encode(earPlugs, forKey: .earPlugs)
    try container.encode(vehicles, forKey: .vehicles)
  }
}

struct HomeNoise : Codable, Equatable {
  var noisy : Int = 0
  var living = OrOther<Living>()
  var sleep = OrOther<OftennessX>()
  var digital = OrOther<Frequentness>()

  enum CodingKeys : String, CodingKey {
    case noisy
    case living
    case sleep
    case digital
  }

  var complete : Bool { get {
    return noisy != 0 && living.complete && sleep.complete && digital.complete
  }}

  init() {
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    noisy = try values.decode(Int.self, forKey: .noisy)
    living = try values.decode(OrOther<Living>.self, forKey: .living)
    sleep = try values.decode(OrOther<OftennessX>.self, forKey: .sleep)
        digital = try values.decode(OrOther<Frequentness>.self, forKey: .digital)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(noisy, forKey: .noisy)
    try container.encode(living, forKey: .living)
    try container.encode(sleep, forKey: .sleep)
        try container.encode(digital, forKey: .digital)
  }

}


struct PerceptionNoise : Codable, Equatable {
  var frustration : Int = 0
  var awoken : Int = 0
  var music : Int = 0
  var relax : Int = 0
  var exposure : Int = 0

  var complete : Bool { get {
    return frustration != 0 && awoken != 0 && music != 0 && relax != 0 && exposure != 0
  }}

  enum CodingKeys : String, CodingKey {
    case frustration
    case awoken
    case music
    case relax
    case exposure
  }

  init() {
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    frustration = try values.decode(Int.self, forKey: .frustration)
    awoken = try values.decode(Int.self, forKey: .awoken)
    music = try values.decode(Int.self, forKey: .music)
    relax = try values.decode(Int.self, forKey: .relax)
    exposure = try values.decode(Int.self, forKey: .exposure)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(frustration, forKey: .frustration)
    try container.encode(awoken, forKey: .awoken)
    try container.encode(music, forKey: .music)
    try container.encode(relax, forKey: .relax)
    try container.encode(exposure, forKey: .exposure)

  }

}






struct Noise : Codable {
  var homeNoise = HomeNoise()
  var workNoise = WorkNoise()
  var perceptionNoise = PerceptionNoise()

  enum CodingKeys : String, CodingKey {
    case homeNoise
    case workNoise
    case perceptionNoise
  }

  init() {
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    homeNoise = try values.decode(HomeNoise.self, forKey: .homeNoise)
    workNoise = try values.decode(WorkNoise.self, forKey: .workNoise)
        perceptionNoise = try values.decode(PerceptionNoise.self, forKey: .perceptionNoise)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(homeNoise, forKey: .homeNoise)
    try container.encode(workNoise, forKey: .workNoise)
        try container.encode(perceptionNoise, forKey: .perceptionNoise)
  }

}

class Survey : ObservableObject, Codable {
  // Demographics
  @Published var age = OrOther<AgeRange>()
  @Published var ethnic = OrOther<EthnicBackground>()
  @Published var gender = OrOther<Gender>()
  @Published var employment = OrOther<Employment>()
  @Published var income = OrOther<Income>()

  // Medical
  @Published var health = Health()

  // Home noise
  @Published var noise = Noise()
  
  var section1Complete : Bool { get {
    return age.complete && ethnic.complete && gender.complete && employment.complete && income.complete
  }}

  enum CodingKeys : String, CodingKey {
    case age
    case ethnic
    case gender
    case music
    case employment
    case income
    case health
    case noise
  }

  required init() { }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    age = try values.decode(OrOther<AgeRange>.self, forKey: .age)
    ethnic = try values.decode(OrOther<EthnicBackground>.self, forKey: .ethnic)
    gender = try values.decode(OrOther<Gender>.self, forKey: .gender)
    employment = try values.decode(OrOther<Employment>.self, forKey: .employment)
    income = try values.decode(OrOther<Income>.self, forKey: .income)
    health = try values.decode(Health.self, forKey: .health)
    noise = try values.decode(Noise.self, forKey: .noise)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(age, forKey: .age)
    try container.encode(ethnic, forKey: .ethnic)
    try container.encode(gender, forKey: .gender)
    try container.encode(employment, forKey: .employment)
    try container.encode(income, forKey: .income)
    try container.encode(health, forKey: .health)
    try container.encode(noise, forKey: .noise)
  }




}

enum SoundKind : Int, MyEnum, Codable {
  case humanVoice
  case humanMovement
  case animalNoise
  case weather
  case construction
  case mechanical
  case transportationRail
  case transportationSurface
  case transportationAir
  case transportationOther
  case music
  
  var description : String {
    switch self {
    case .humanVoice: return "Human Voice"
    case .humanMovement: return "Human Movements"
    case .animalNoise: return "Animal Noise"
    case .weather: return "Weather"
    case .construction: return "Construction"
    case .mechanical: return "Mechanical Equipment"
    case .transportationRail: return "Transportation (Subway/Train)"
    case .transportationSurface: return "Transportation (Cars/Trucks/Buses)"
    case .transportationAir: return "Transportation Air (Planes/Helicopters)"
    case .transportationOther: return "Transporation (Other)"
    case .music: return "Music"
    }
  }
}

class Annoyance : Codable, ObservableObject {
  @Published var annoying : Int = 0 // 1-10
  @Published var control : Int = 0 // 1-5
  @Published var kind = OrOther<SoundKind>()
  
  enum CodingKeys : String, CodingKey { case annoying, control, kind }
  
  var isFilledOut : Bool {
    return annoying != 0 && control != 0  &&  ( kind.choice != nil || (kind.other != nil && !kind.other!.isEmpty))
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(annoying, forKey: .annoying)
    try container.encode(control, forKey: .control)
    try container.encode(kind, forKey: .kind)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    annoying = try container.decode(Int.self, forKey: .annoying)
    control = try container.decode(Int.self, forKey: .control)
    kind = try container.decode(OrOther<SoundKind>.self, forKey: .kind)
  }
  
  init() {
  }
}
