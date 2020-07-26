
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
        
        PlayButton().onTapGesture {
          print("play")
        }
        Text(recording.displayName).font(.largeTitle)
        Text(String(describing:recording.location))
        HStack {
          Text(String(format: "Leq: %.2f", recording.leq))
        }
        Button( action: { uploadToS3(url: recording.url, location: recording.location, annoyance: recording.annoyance) }) {
          Text("Upload to S3")
        }


        GeometryReader { g in
          if let rl = self.recording.location {
            MapView(centerCoordinate: .constant(rl.coordinate)).layoutPriority(0.2)
              .padding((print(g), 0).1 + 20).frame(minHeight: 50)
          }
        }.layoutPriority(0.3)

        //          Text( String(describing: self.recorder.onAir?.leq) )
        //          Text( self.recorder.onAir?.displayName ?? "")

        //          MeterView(value: self.recording.avgSamples).padding(10)



        // NavigationView {
        AnnoyanceForm(annoyance: $recording.annoyance)
          .frame(minHeight: 300)
          .layoutPriority(0.3)




        Text("metadata for recording here").layoutPriority(0.1)



        //          ProgressBar(value: self.$recorder.percentage).layoutPriority(0)
        Spacer().layoutPriority(0.1)
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
