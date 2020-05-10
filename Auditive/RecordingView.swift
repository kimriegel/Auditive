
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
          Button( action: { self.recording.uploadToS3() }) {
            Text("Upload to S3")
          }

 /*
 MapView(centerCoordinate: .constant(self.recorder.myLocation!.coordinate)).layoutPriority(0.2)
            .padding(20)

          Text("metadata for recording here").layoutPriority(0.1)
          Text( String(describing: self.recorder.onAir?.leq) )
          Text( self.recorder.onAir?.displayName ?? "")

          MeterView(value: self.$recorder.recording.avgSamples).padding(10)


          ProgressBar(value: self.$recorder.percentage).layoutPriority(0)
          Spacer().layoutPriority(0.1)
*/
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
