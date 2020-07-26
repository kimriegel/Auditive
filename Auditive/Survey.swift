//// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation

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
      return "Other"
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
    case .construction: return "Consttruction"
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
  var annoying : Int = 0 // 1-10
  var control : Int = 0 // 1-5
  var kind = OrOther<SoundKind>()
}
