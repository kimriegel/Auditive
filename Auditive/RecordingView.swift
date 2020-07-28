
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI


struct AnnoyanceForm : View {
  @Binding var annoyance : Annoyance

  var body: some View {
    Form {
      Section(header: Text("Annoyance data")) {

        RatingView(rating: $annoyance.annoying, label: "How annoying does this sound feel to you?",
                   maximumRating: 10)
        RatingView(rating: $annoyance.control, label: "How much control do you have over the sound (i.e.  can you turn it off/walk away)?",
                   maximumRating: 5)

        EnumWheelView(label: "What kind of sound is this?", pick: self.$annoyance.kind, allowOther: true) // SegmentPickerStyle)(
      }
    }
  }
}

struct RecordingView: View {

  @ObservedObject var recording : Recording

  var body: some View {
    ScrollView {
      VStack {

        if self.recording.onAir {
          Text("Stop recording").foregroundColor(Color.black)
            // g.size.width
            .frame(width: UIScreen.screens[0].bounds.width - 40)
            .padding(EdgeInsets.init(top: 20, leading: 0, bottom: 20, trailing: 0))
            .background( Color.green )
            .onTapGesture {
              self.recording.stop()
            }
        } else if self.recording.audioFile == nil {
          RecordButton()
            .onTapGesture {
              self.recording.startRecordingSample()
              // self.recorder.objectWillChange.send()
            }
        } else {
          PlayButton().onTapGesture {
            print("play")
          }
        }

        Text(recording.displayName).font(.largeTitle)
        //        Text(String(describing:recording.location))

        if self.recording.audioFile != nil {
          HStack {
            Text(String(format: "Leq: %.2f", recording.leq))
          }
          Button( action: { uploadToS3(url: self.recording.url, location: self.recording.location, annoyance: self.recording.annoyance) }) {
            Text("Upload to S3")
          }
        }



      GeometryReader { g in
          if nil != self.recording.location {
            MapView(centerCoordinate: .constant(self.recording.location!.coordinate)).layoutPriority(0.2)
              .padding(20).frame(minHeight: 50)
          }
        }.layoutPriority(0.3)

        //          Text( String(describing: self.recorder.onAir?.leq) )
        //          Text( self.recorder.onAir?.displayName ?? "")

        //          MeterView(value: self.recording.avgSamples).padding(10)

        if self.recording.onAir {
          VStack {
            OnAirView(recording: self.recording)

            MyProgressBar(value: self.recording.percentage).layoutPriority(0)
            Spacer().layoutPriority(0.1)
          }
        }

        // NavigationView {
        AnnoyanceForm(annoyance: $recording.annoyance)
          .frame(minHeight: 300)
          .layoutPriority(0.3)

        //          ProgressBar(value: self.$recorder.percentage).layoutPriority(0)
        Spacer().layoutPriority(0.1)

        if self.recording.audioFile != nil {
          HStack {
            Button(action: {
              print("submit")
            }) {
              Text("Submit")
            }.background(Color.green)
            Button(action: {
              print("discard")
            }) {
              Text("Discard")
            }.background(Color.red)
          }
        }
      }
    }
    .onDisappear {
      self.recording.ap?.stop()
      // write out the annoyance form data?

      print("recording disappeared")
    }
  }
}

struct RecordingView_Previews: PreviewProvider {
  static var previews: some View {
    RecordingView(recording: Recording(URL(string: "https://example.com")!))
  }
}
