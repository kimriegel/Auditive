protocol MyEnum : CaseIterable {
  var description : String { get }
}

enum AgeRange : Int, MyEnum, Codable {
  case unspecified
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
    case .unspecified: return "Pick one"
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

enum OrOther<T : MyEnum> : MyEnum {
  static var allCases: [OrOther<T>] {
    return T.allCases.map { .choice($0) } + [Self.other("unspecified")]
  }

  var description: String {
    switch self {
    case .choice(let a): return a.description
    case .other(let a): return "Other (please specify)"
    }
  }

  typealias AllCases = [OrOther<T>]

  case choice(T)
  case other(String)
}


let t = OrOther<AgeRange>.choice(._17)

t as? OrOther<some MyEnum>
