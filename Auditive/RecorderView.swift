
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import MapKit

struct MeterView : View {
  @Binding var value : [Float]

  var body : some View {
    HStack(alignment: .bottom,  spacing: 5) {
//      GeometryReader { g in
      ForEach(self.value, id: \.self) { v in
        ZStack {
        Rectangle()
          .fill(Color.purple)
          .frame(width: 50, height: 100 * CGFloat(v), alignment: .bottom)
        }.frame(height: 100, alignment: .bottom).background(Color.green)
      }.frame(height: 100).background(Color.purple)
//      }
    }
  }
}

// The view when recording a new clip
struct RecorderView: View {
  @ObservedObject var recorder : Recorder
  //  @ObservedObject var recording : Recording
  
  var body: some View {
    GeometryReader { g in
      VStack {
        Spacer().layoutPriority(0.1)

        if self.recorder.onAir {
          Text("Stop recording").foregroundColor(Color.black)
            .frame(width: g.size.width - 40)
            .padding(EdgeInsets.init(top: 20, leading: 0, bottom: 20, trailing: 0))
            .background( Color.green )
            .onTapGesture {
              self.recorder.stop()
          }
        } else {
          Text("Re-record").foregroundColor(Color.black)
            .frame(width: g.size.width - 40)
            .padding(EdgeInsets.init(top: 20, leading: 0, bottom: 20, trailing: 0))
            .background( Color.red)
            .onTapGesture {
              self.recorder.startRecordingSample()
          }
        }

        //        .layoutPriority(0.1)

        MapView(centerCoordinate: .constant(self.recorder.myLocation!.coordinate)).layoutPriority(0.2)
          .padding(20)

        Text("metadata for recording here").layoutPriority(0.1)
        Text( String(describing: self.recorder.recording.leq) )
        Text( self.recorder.recording.displayName)

        MeterView(value: self.$recorder.recording.avgSamples).padding(10)


        ProgressBar(value: self.$recorder.percentage).layoutPriority(0)
        Spacer().layoutPriority(0.1)
      }.onAppear {
        self.recorder.startRecordingSample()
        print("recorder appeared")
      }
    }
  }
}

/*
 struct RecorderView_Previews: PreviewProvider {
 static var previews: some View {
 RecorderView(recorder: Recorder() )
 }
 }
 */
