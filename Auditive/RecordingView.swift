
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct RecordingView: View {
  let recording : Recording

    var body: some View {
        VStack {
          Text(recording.displayName)
                .font(.largeTitle)
          Text(String(describing:recording.location))
          HStack {
            Text(String(format: "Leq: %.2f", recording.leq))
          }
          Button( action: { uploadToS3(url: recording.url, location: recording.location) }) {
            Text("Upload to S3")
          }


          GeometryReader { g in
 MapView(centerCoordinate: .constant(self.recording.location!.coordinate)).layoutPriority(0.2)
  .padding((print(g), 0).1 + 20)
          }.layoutPriority(0.3)
          Text("metadata for recording here").layoutPriority(0.1)
//          Text( String(describing: self.recorder.onAir?.leq) )
//          Text( self.recorder.onAir?.displayName ?? "")

//          MeterView(value: self.recording.avgSamples).padding(10)


//          ProgressBar(value: self.$recorder.percentage).layoutPriority(0)
          Spacer().layoutPriority(0.1)

        }.onAppear {
          self.recording.play()
          print("recording appeared")
          }
        .onDisappear {
          self.recording.ap.stop()
          print("recording disappeared")
      }
  }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
      RecordingView(recording: Recording(URL(string: "https://example.com")!))
    }
}
