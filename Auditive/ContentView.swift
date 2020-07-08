
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import AVFoundation

/*struct SwipeableText : View {
 @State var offset : CGSize = .zero

 let string : String
 var recording : Recording

 var body: some View {
 let drag = DragGesture()
 .onChanged { self.offset = $0.translation
 print("clem \(self.offset)")
 }
 .onEnded {
 print("ended?")
 if $0.translation.width < -100 {
 self.offset = .init(width: -1000, height: 0)
 self.recording.delete()
 //              self.selection.x = nil
 print("left")
 } else if $0.translation.width > 100 {
 self.offset = .init(width: 1000, height: 0)
 self.recording.delete()
 //              self.selection.x = nil
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
 */

var refreshers : [SampleListView] = []
var observer  = DirectoryObserver(URL: Recording.mediaDir) {
  // DispatchQueue.main.async { refreshers.forEach { $0.needsRefresh.x.toggle() }  }
}

struct ContentView : View {
  @State var needsRefresh : Bool = false

  var body : some View {
    VStack {
      if needsRefresh || !needsRefresh {
        if UserDefaults.standard.bool(forKey: Key.hasConsented) {
          if nil != UserDefaults.standard.string(forKey: Key.healthSurvey) {
        SampleListView()
      } else {
        SurveyView(needsRefresh: self.$needsRefresh)
      }
    } else {
      ConsentView(needsRefresh: self.$needsRefresh)
    }
    }
  }
}
}


struct SampleListView: View {
  @ObservedObject var sel = Observable<Int?>(1) { nv in
    if let nv = nv {
      print("nv:",nv)
    }
  }

  @ObservedObject var needsRefresh = Observable<Bool>(false)


  init() {
    print(observer)
    refreshers.append(self)
  }
  
  @ObservedObject var recorder = Recorder()


  var body: some View {

    NavigationView {
        VStack {
          NavigationLink(destination: RecorderView(recorder: self.recorder)) {
            //        Button(action: {
            //          self.recorder.startRecordingSample()
            //        }) {
            RecordButton()
//            Text("Record").foregroundColor(Color.black)
//              .frame(width: g.size.width - 40)
//              .padding(EdgeInsets.init(top: 20, leading: 0, bottom: 20, trailing: 0))
//              .background( self.recorder.onAir ? Color.gray : Color.red)
            //        }
            //          .disabled( self.recorder.onAir)
          }
          //        List.init(0..<self.recordingsX.recordingNames.count, selection: self.$sel.x) { x in
          List(selection: self.$sel.x) {
            ForEach(self.recorder.recordings, id: \.self) { z in
              
              NavigationLink(destination: RecordingView(recording: z)) {
                Text( z.displayName).background(Color.orange) // .background( x == self.sel.x ? Color.gray : Color.white)
              }.background(Color.green)
            }.background(Color.blue)
          }
          .background(Color.orange)
        }.navigationBarTitle(Text("Urban Samples"))
//          .background(Color.pink)
//        .contrast(self.needsRefresh.x ? (
//          self.needsRefresh.x.toggle() , 1).1 : 0.9)
      }

  }
  
  func play(_ z : Recording){
    z.play()
  }
  
  func delete(at offsets: IndexSet) {
    offsets.forEach { print($0) }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
