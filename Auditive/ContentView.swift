
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import AVFoundation

var refreshers : [SampleListView] = []
var observer  = DirectoryObserver(URL: Recording.mediaDir) {
  // DispatchQueue.main.async { refreshers.forEach { $0.needsRefresh.x.toggle() }  }
}

struct ContentView : View {
  @State var uuid = UUID()

  let pub = NotificationCenter.default.publisher(for: Notification.Name.savedSurvey)
    .merge(with: NotificationCenter.default.publisher(for: Notification.Name.savedConsent))

  var body : some View {
    ZStack {
      Text(uuid.uuidString).hidden()
      VStack {
        if UserDefaults.standard.bool(forKey: Key.hasConsented) {
          if nil != UserDefaults.standard.string(forKey: Key.healthSurvey) {
            SampleListView()
          } else {
            SurveyView()
          }
        } else {
          ConsentView()
        }
      }.onReceive(pub) { _ in
        self.uuid = UUID()
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
    let j = Recorder()
    rv = RecorderView(recorder: j)
    recorder = j
    refreshers.append(self)
  }

  var rv : RecorderView
  @ObservedObject var recorder : Recorder
  @State var isRecording: Bool = false

  var body: some View {
    NavigationView {
      VStack {
        NavigationLink( destination: rv, isActive: $isRecording ) {
          RecordButton().onTapGesture {
            self.recorder.startRecordingSample()
            isRecording = true
          }
        }
        List(selection: self.$sel.x) {
          ForEach(self.recorder.recordings, id: \.self) { z in
            NavigationLink(destination: RecordingView(recording: z)) {
              Text( z.displayName).background(Color.orange)
            }.background(Color.green)
          }.background(Color.blue)
        }
        .background(Color.orange)
      }.navigationBarTitle(Text("Urban Samples"))
    }
  }
  
  func play(_ z : Recording) {
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
