
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import AVFoundation

struct ContentView : View {
  @State var uuid = UUID()
  @AppStorage("show_survey") var show_survey : Bool = false
  @AppStorage(Key.savedSurvey) var survey_uploaded : Bool = false
  @AppStorage(Key.hasConsented) var hasConsented : Bool = false

  let pub = NotificationCenter.default.publisher(for:   Notification.Name.deletedFile)
    .merge(with: NotificationCenter.default.publisher(for: Notification.Name.addedFile))
    .merge(with: NotificationCenter.default.publisher(for:
                                                        Notification.Name.completedSurvey))

  var body : some View {
    ZStack {
      VStack {
        if hasConsented {
          let hs = UserDefaults.standard.string(forKey: Key.healthSurvey)
          let hsx = hs == nil ? nil : try? JSONDecoder().decode(Survey.self, from: hs!.data(using: String.Encoding.utf8)!)
          if nil != hsx && !show_survey && survey_uploaded {
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
  @AppStorage("numberOfUploads") var nos : Int = 0

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
      }.navigationBarTitleDisplayMode(.inline)
      .toolbar(content: {
        ToolbarItem(placement: .principal, content: {
          VStack {
            Text("Urban Samples")
            Text("uploaded \(nos) samples").font(.system(size: 10))
          }
        })})
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
