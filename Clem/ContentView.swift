//
//  ContentView.swift
//  Clem
//
//  Created by Robert Lefkowitz on 10/23/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

import SwiftUI

struct SwipeableText : View {
  @State var offset : CGSize = .zero
  let string : String

  var body: some View {
    let drag = DragGesture()
         .onChanged { self.offset = $0.translation
          print("clem \(self.offset)")
    }
         .onEnded {
          print("ended?")
             if $0.translation.width < -100 {
                 self.offset = .init(width: -1000, height: 0)
              print("left")
             } else if $0.translation.width > 100 {
                 self.offset = .init(width: 1000, height: 0)
              print("right")
             } else {
              print("nope")
                 self.offset = .zero
             }
          print("zem")
     }

    return Text(string)
    .offset(x: self.offset.width, y: 0)
     .simultaneousGesture(drag)
     .animation(.spring())

  }
  
}


struct ContentView: View {
  @State var recordings: [String] = []
  @ObservedObject var sel = Observable<Int?>(1) { nv in
    if let nv = nv {
      print(nv)
    }
  }
  
  var recordingsX = Recordings()
  
  var body: some View {

    NavigationView {
      GeometryReader {g in
        VStack {
        Button(action: {
          self.recordingsX.startRecordingSample()
        }) {
          Text("Record").foregroundColor(Color.black)
        }.frame(width: g.size.width - 40)
          .padding(EdgeInsets.init(top: 20, leading: 0, bottom: 20, trailing: 0))
          .background(Color.red)
//        List.init(0..<self.recordingsX.recordingNames.count, selection: self.$sel.x) { x in
          List(selection: self.$sel.x) {
            ForEach(self.recordingsX.recordings, id: \.self) { z in
              
               
         
              SwipeableText(string: z.displayName) // .background( x == self.sel.x ? Color.gray : Color.white)
 
            } // .onDelete(perform: self.delete)

        }.navigationBarItems(trailing: EditButton())
          
        }
      }
    }
  }
  
  func delete(at offsets: IndexSet) {
    offsets.forEach { print($0) }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(recordings: ["abc", "def", "ghi"])
  }
}
