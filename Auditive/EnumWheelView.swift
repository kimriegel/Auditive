// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

fileprivate struct SplitOut<T:MyEnum> : View {
  let x : Int

  var body : some View {
    if x == 0 {
      Text(OrOther<T>().description)
    }
    if x == T.allCases.count+1 {
      Text(OrOther<T>(other: "").description)
    }
    if x > 0 && x < T.allCases.count + 1 {
      Text(T.allCases[(x - 1) as! T.AllCases.Index].description)
    }
  }
}

struct EnumWheelView<T : MyEnum > : View {
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
      let p = Picker(selection: Binding(get: {self.selection },
                                set: {
                                  self.pick = OrOther.pick($0)
                                  self.selection = $0
                                }),
             label: Text(label)
      ) {
        ForEach(0..<c) { ee in
          VStack {
            SplitOut<T>(x:ee )
/*          if allowOther && ee == c-1 {
            TextField.init("Other", text: Binding(get: { self.pick.other ?? ""},
                                                  set: {
                                                    print("setting other to \($0)")
                                                          self.pick.other = $0} ))
          }
 */
          }
        }
      }

    let j = VStack {
      p
      if self.pick.other != nil {
        TextField.init("Please specify", text: Binding(get: { self.pick.other ?? "Please specify"},
                                              set: {
                                              //  print("setting other to \($0)")
                                                self.pick.other = $0} ))
          .autocapitalization(.words).multilineTextAlignment(.trailing)

      }
    }
    return j
//      .frame(width: 800)

//      Spacer().layoutPriority(5)
//    }.padding(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 30))
//  }
 }
}


struct EnumWheelView_Previews: PreviewProvider {
  @State static var race = OrOther<Race>()
  static var previews: some View {
      EnumWheelView(label: "Race", pick: self.$race, allowOther: true)
    }
}
