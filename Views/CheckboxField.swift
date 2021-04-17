// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct CheckboxField: View {
  let label: String
  let id : Int
  @Binding var marked : Int?
  let size : CGFloat = 14
  let color = Color.black


  var body: some View {
    Button(action:{
      self.marked = id
    }) {
      HStack(alignment: .center, spacing: 10) {
        Image(systemName: self.id == self.marked ? "checkmark.square" : "square")
          .renderingMode(.original)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: self.size, height: self.size)
        Text(label)
          .font(Font.system(size: self.size))
        Spacer()
      }.foregroundColor(self.color)
    }.background(Color.white).padding(10)
  }
}

