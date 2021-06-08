// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct CheckBox: View {
  @Binding var value : Bool

  var label : String
  
  @State var toggled = false
      var body: some View {
//Button(action:{
//          self.value.toggle()
//          self.toggled.toggle()
//        }) {
            Image(systemName: "checkmark")
              .renderingMode(.original)
              .resizable()
              .opacity( self.value ? 1 : 0)
              .aspectRatio(contentMode: .fit)
              .frame(width: 15, height: 15)
              .padding(5)
              .contentShape(Rectangle())
              .onTapGesture {
                 value.toggle()
              }
//          }.padding(5)
//        .background(self.toggled ? Color.yellow : Color.clear)
      }
}

struct CheckBox_Previews: PreviewProvider {
    static var previews: some View {
      VStack {
        CheckBox(value: .constant(true), label: "Test true")
        CheckBox(value: .constant(false), label: "Test false")
      }
    }
}
