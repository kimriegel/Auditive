
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct AnnoyanceForm : View {
  @ObservedObject var annoyance : Annoyance

  var body: some View {
    //    Form {
    //  Section(header: Text("Annoyance data")) {
    GroupBox {
      Rater(rating: $annoyance.annoying, label: "How annoying is the noise?",
            maximumRating: 10)
      Rater(rating: $annoyance.control, label: "How much control do you have over it?",
            maximumRating: 5)

      XPick(label: "What kind of sound is it?", pick: self.$annoyance.kind, allowOther: true) // SegmentPickerStyle)(
    }
  }
  //  }
  //  }
}

struct RecordingView: View {

  @AppStorage("numberOfUploads") var numberOfUploads : Int = 0
  @Environment(\.presentationMode) var presentationMode

  let dqb = DispatchQueue.global()
  @ObservedObject var recording : Recording
  // @ObservedObject var annoyance : Annoyance
  //  @State var uuid : UUID = UUID()
  @State var formIsFilledOut : Bool

  init(recording r : Recording) {
    recording = r
    _formIsFilledOut = State(initialValue: r.annoyance.isFilledOut)
  }

  var body: some View {
    /*    DispatchQueue.main.async {
     formIsFilledOut = recording.annoyance.isFilledOut
     }
     return
     */ VStack {
       VStack(spacing: 0) {
         if self.recording.isRecording {
           StopButton()
           /*          Text("Stop recording").foregroundColor(Color.black)
            // g.size.width
            .frame(width: UIScreen.screens[0].bounds.width - 40)
            .padding(EdgeInsets.init(top: 20, leading: 0, bottom: 20, trailing: 0))
            .background( Color.green )
            */
             .onTapGesture {
               self.recording.stop()
               NotificationCenter.default.post(Notification(name: .stoppedRecording))
             }
           /*        } else if self.recording.audioFile == nil {
            RecordButton()
            .onTapGesture {
            self.recording.startRecordingSample()
            // self.recorder.objectWillChange.send()
            }
            */        } else {
              PlayButton()
                .onTapGesture {
                  self.recording.play()
                }.disabled(self.recording.isPlaying)
                .opacity(self.recording.isPlaying ? 0.5 : 1)
            }

         Text(recording.displayName).font(.headline)
         //        Text(String(describing:recording.location))

         if !self.recording.isRecording {
           HStack {
             Text(String(format: "Leq: %.2f", recording.leq))
           }

         }

         GeometryReader { g in
           if nil != self.recording.location {
             MapView(centerCoordinate: .constant(self.recording.location!.coordinate)).layoutPriority(0.4)
               .padding(20).frame(minHeight: 150).disabled(true)
           }
         }.layoutPriority(0.3).frame(minHeight: 150)

         //          Text( String(describing: self.recorder.onAir?.leq) )
         //          Text( self.recorder.onAir?.displayName ?? "")

         //          MeterView(value: self.recording.avgSamples).padding(10)

         if self.recording.isRecording {
           VStack {
             OnAirView(recording: self.recording)

             MyProgressBar(value: self.recording.percentage).layoutPriority(0)
             Spacer().layoutPriority(0.1)
           }
         }
       }.padding(0)

       // NavigationView {
       AnnoyanceForm(annoyance: recording.annoyance)
         .layoutPriority(0.3)
         .onReceive(recording.annoyance.objectWillChange) {

           dqb.async {

             if let a = try? JSONEncoder().encode(self.recording.annoyance) {
               do {
                 try XAttr(self.recording.url).set(data: a, forName: Key.annoyance)
               } catch (let e){
                 print(e)
               }
             }
             if self.recording.annoyance.isFilledOut != formIsFilledOut {
               // uuid = UUID()
               formIsFilledOut.toggle()
             }
           }
         }
       //          ProgressBar(value: self.$recorder.percentage).layoutPriority(0)
       // Spacer().layoutPriority(0.1)
       HStack {
         Spacer()
         //        if self.recording.annoyance.isFilledOut {
         Button( action: {
           let _ =  uploadToS3(url: self.recording.url, location: self.recording.location, annoyance: self.recording.annoyance)
           numberOfUploads += 1
           presentationMode.wrappedValue.dismiss()
           self.recording.delete() // delete the local recording after the upload succeeds
         }) {
           HStack {
             Image(systemName: "icloud.and.arrow.up.fill")
             Text("Submit")
           }.font(.title).padding(10)
         }.background(Color.green).foregroundColor(Color.black)
           .opacity( formIsFilledOut ? 1 : 0)
           .disabled(!formIsFilledOut)

           .frame(maxWidth:.infinity)
         Spacer()
         //                    }
         Button( action: {
           presentationMode.wrappedValue.dismiss()
           self.recording.delete() }) {
             HStack {
               Image(systemName: "trash")
               Text("Discard")
             }.font(.title).padding(10)


           }.background(Color.red).foregroundColor(Color.black)
           .frame(maxWidth: .infinity)
         Spacer()
       }

       //    }
     }// .navigationBarHidden(false)
     .navigationBarTitleDisplayMode(.inline)
     .toolbar(content: {
       ToolbarItem(placement: .principal, content: {
         Text("Recording")
       })})
    //    .listStyle(GroupedListStyle())
    //    .environment(\.horizontalSizeClass, .compact)
     .onDisappear {
       self.recording.ap?.stop()
     }.keyboardAdaptive()
  }
}

struct RecordingView_Previews: PreviewProvider {
  static var previews: some View {
    RecordingView(recording: Recording(URL(string: "https://example.com")!))
  }
}
