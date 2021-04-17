// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

fileprivate struct SplitOut<T:MyEnum> : View {
  let x : Int
  typealias U = OrOther<T>

  var body : some View {
    if x == 0 {
      return Text(U().description)
    }
    if x == T.allCases.count+1 {
      return Text(U(other: "").description)
    }
    if x > 0 && x < T.allCases.count + 1 {
      return Text(T.allCases[(x - 1) as! T.AllCases.Index].description)
    }
    // Should never get here
    return Text("")
  }
}

struct MenuPick<T : MyEnum> : View {
  let label: String
  @Binding var ss : OrOther<T>
  @State var p : String = ""
  let allowOther : Bool

  init(label: String, pick s : Binding<OrOther<T>>, allowOther : Bool) {
    self.label = label
    self.allowOther = allowOther
    _ss = s
    p = ss.description
  }

  var body : some View {
    HStack {
      Menu( label  ) {
        ForEach(0..<T.allCases.count, id: \.self) { ee in

          Button(action: {
            ss = OrOther(choice: T.allCases[ee as! T.AllCases.Index])
            p = ss.description
          }) {
            Text( T.allCases[ee as! T.AllCases.Index].description )
          }
        }
        if allowOther {
          Button(action: {
            ss = OrOther<T>(other: "")
            p = ss.description
          }) {
            Text("Other")
          }
        }
      }

      if ss.other != nil {
        ZStack {
          TextField("other:", text: Binding(get: {ss.other ?? ""}, set: {
            ss.other = $0
            ss.choice = nil
            p = $0
          }))

          Text(p).hidden()
        }
      } else {
        Text(p)
      }
    }
  }
}


/*
struct EnumWheelView<T : MyEnum > : View {
  let label : String
  @Binding var pick : OrOther<T>
  let allowOther : Bool

  @State var selection : Int = 0

  func calcSelection() -> Int {
    if let _ = pick.other {
      return  T.allCases.count+1
    } else if let c = self.pick.choice {
      return 1 + (T.allCases.firstIndex(of: c) as? Int ?? -1)
    } else {
      return 0
    }
  }

  init(label: String, pick : Binding<OrOther<T>>, allowOther: Bool) {
    self.label = label
    self._pick = pick
    self.allowOther = allowOther
    selection = calcSelection()
  }

  var body: some View {
    VStack {
      Picker(selection: Binding(get: { self.calcSelection() },
                                set: {
                                  self.pick = OrOther.pick($0)
                                  self.selection = $0
                                }),
             label: Text(label)
      ) {
        ForEach(0..<T.allCases.count+1+(allowOther ? 1 : 0), id: \.self) { ee in
          VStack {
            SplitOut<T>(x:ee )
          }
        }
      }
      if self.pick.other != nil {
        TextField.init("Specify Other", text: Binding(get: { self.pick.other ?? "other?"},
                                                      set: {
                                                        // This strangeness is required to trigger the "pick" assignement (which stores the data in an XAttr on the file
                                                        let k = self.pick
                                                        k.other = $0
                                                        self.pick = k
                                                      } ))
          .autocapitalization(.words).multilineTextAlignment(.leading).padding(7)

      }
    }
  }
}


struct EnumWheelView_Previews: PreviewProvider {
  @State static var race = OrOther<Race>()
  static var previews: some View {
    EnumWheelView(label: "Race", pick: self.$race, allowOther: true)
  }
}
*/
