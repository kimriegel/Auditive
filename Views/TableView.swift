// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

protocol Booler {
  var label : String {get}
  var bools : [Bool] {get set}
//  static var size : Int { get }
  static var labels : [String] { get }
}

struct TableView<T : Booler>: View {
  @Binding var list : [T]

  var body: some View {

      VStack(spacing: -2) {
        Spacer(minLength: 14)
        HStack(spacing: -2) {
          Text(T.labels[0]).frame(maxWidth:.infinity, alignment: .leading)
          ForEach(1..<T.labels.count) { j in
            Text(T.labels[j]).frame(minWidth: 40)
          }
        }
        Spacer(minLength: 8)
      ForEach.init(0..<list.count) { i in
        HStack(spacing: -2) {

          Text(list[i].label)
            .frame(maxWidth:.infinity, minHeight: 25, alignment: .leading)
            .padding([.leading, .trailing], 10)
            .border(Color.green, width: 2)
            .allowsTightening(false)

          ForEach(0..<T.labels.count-1) { j in
          CheckBox(value: $list[i].bools[j], label: list[i].label)
            .frame(minWidth: 40)
            .border(Color.green, width: 2)
          }
        }.frame(maxWidth: .infinity)
    }
      }
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
      TableView(list: .constant(["abc", "defg", "higk"].map { HealthCondition($0) }) )
    }
}
