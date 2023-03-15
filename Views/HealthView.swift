// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct HealthView2 : View {
  @Binding var health : Health

  var body : some View {
    VStack {
  Text("Have you ever experienced any of the following symptoms (check all that apply)")
  TableView(list: $health.symptoms )
      Spacer(minLength: 20)
      Group {


        PickerView(label: "I smoke cigarettes", pick: $health.smoking )
        Spacer(minLength: 30)
        PickerView(label: "I drink alcohol", pick: $health.drinking)
      }

    }
  }
}

struct HealthView : View {
  @Binding var health : Health

  var body : some View {

    VStack {

      Text("Have you or your family member ever been diagnosed with (please check all that apply)")
      TableView(list: $health.conditions ) //.padding(4)



//    }.onChange(of: none) { x in
//      if x {
//        health.clearAll()
//      }
//    }.onReceive(health.objectWillChange) {
//      if health.anyTrue {
//        none = false
//      }
//    }
    }
  }
}

struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
      HealthView(health: .constant(Survey().health) )
    }
}
