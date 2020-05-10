
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct ProgressBar: View {
  @Binding var value: CGFloat

  var percentage : Int { get {
    return Int(ceil(value * 100))
    }
  }

  func barWidth(geometry: GeometryProxy) -> CGFloat {
    let frame = geometry.frame(in: .global)
    return frame.size.width * value
  }
  var body: some View {
    GeometryReader { g in
      VStack(alignment: .trailing) {
        ZStack(alignment: .leading) {
          Rectangle().opacity(0.1)
          Rectangle()
            .frame(minWidth: 0, idealWidth: self.barWidth(geometry: g),
                   maxWidth: self.barWidth(geometry: g))
            .opacity(0.5)
            .background(Color.green)
            .animation(.default)
        }.frame(height: 10)
      }.frame(height: 10).padding(20)
    }
  }
}

struct ProgressBar_Previews: PreviewProvider {
  @State static var value = CGFloat(0.5)
  static var previews: some View {
    ProgressBar(value: $value)
  }
}
