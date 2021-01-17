
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import AVFoundation

struct ContentView : View {
  @State var uuid = UUID()

  let pub = NotificationCenter.default.publisher(for: Notification.Name.savedSurvey)
    .merge(with: NotificationCenter.default.publisher(for: Notification.Name.savedConsent))
    .merge(with: NotificationCenter.default.publisher(for: Notification.Name.deletedFile))
    .merge(with: NotificationCenter.default.publisher(for: Notification.Name.addedFile))

  var body : some View {
    ZStack {
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
      Text(uuid.uuidString).hidden()
    }
  }
}

struct SampleListView: View {
  @State var sel : Int?
  var rv : RecordingView
  @ObservedObject var recording : Recording
  @State var isRecording: Bool = false

  init() {
    let j = Recording()
    rv = RecordingView(recording: j)
    recording = j
  }

  var body: some View {
    NavigationView {
      VStack {
        NavigationLink( destination: rv, isActive: $isRecording ) {
          RecordButton()
            .onTapGesture {
            self.recording.startRecordingSample()
            self.isRecording = true
            }.onReceive(NotificationCenter.default.publisher(for: Notification.Name.stoppedRecording)) { _ in
              self.isRecording = false
            }
        }
        List(selection: self.$sel) {
          ForEach(Recording.recordings, id: \.self) { z in
            NavigationLink(destination: RecordingView(recording: z)) {
              Text( z.displayName)
            }
          }
        }
      }.navigationBarTitle(Text("Urban Samples"))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
