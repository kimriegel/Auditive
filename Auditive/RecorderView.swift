
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import MapKit

struct RecordButton : View {
  let outerRadius : CGFloat = 50
  let innerRadius : CGFloat = 30

  var body: some View {
    let conic = RadialGradient(gradient: Gradient(colors: [.white, .black]),
                               center: .center, startRadius: innerRadius, endRadius: outerRadius)
    return
      VStack {
        ZStack {
          Circle().fill(conic).frame(width: outerRadius * 2, height: outerRadius * 2)
          Circle().fill(Color.red).frame(width: innerRadius * 2, height: innerRadius * 2)
        }
        Text("Record").foregroundColor(.red).font(.footnote).bold()
    }
  }
}

struct RecorderButton_Previews: PreviewProvider {
  static var previews: some View {
    RecordButton()
  }
}

struct Triangle : Shape {
  func path(in rect: CGRect) -> Path {
      var path = Path()

    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
      path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
      path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
      path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

      return path
  }
}

struct PlayButton : View {
  let outerRadius : CGFloat = 50
  let innerRadius : CGFloat = 30

  let lightGreen = Color.init(red: 79.0/255, green: 170.0/255, blue: 79.0/255)
  let darkGreen = Color.init(red: 12.0/255, green: 30.0/255, blue: 12.0/255)
  let lightGray = Color.init(red: 200.0/255, green: 200.0/255, blue: 200.0/255)

  var body: some View {
    let conic = RadialGradient(gradient: Gradient(colors: [darkGreen, lightGreen]),
                               center: .center, startRadius: .zero, endRadius: outerRadius)
    let wipe = LinearGradient(gradient: Gradient(colors: [lightGray, .white]), startPoint: .zero, endPoint:   UnitPoint(x: 1, y: 0))

    return
      VStack {
        ZStack {
          Circle().fill(conic).frame(width: outerRadius * 2, height: outerRadius * 2)
          Triangle().fill(wipe).frame(width: innerRadius * 2, height: innerRadius * 2)
            .padding([.leading], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        Text("Play").foregroundColor(.green).font(.footnote).bold()
    }
  }
}

struct Play_Previews: PreviewProvider {
  static var previews: some View {
    PlayButton()
  }
}

struct MultiMeterView : View {
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


struct MeterView : View {
  @Binding var value : Float // in percent (e.g. 0-100)

  var body : some View {
    HStack(alignment: .bottom,  spacing: 5) {
//      GeometryReader { g in
        ZStack {
        Rectangle()
          .fill(Color.purple)
          .frame(width: 50, height: CGFloat(value), alignment: .bottom)
        }.frame(height: 100, alignment: .bottom).background(Color.green)
      }.frame(height: 100).background(Color.purple)
//      }
  }
}


struct OnAirView : View {
  @ObservedObject var recording : Recording

  var body : some View {
    VStack {
    Text("metadata for recording here").layoutPriority(0.1)

    // FIXME: this can't calculate LEQ while recording
    Text(String(format: "Leq: %.2f", self.recording.leq))

    Text( self.recording.displayName)

      MeterView(value: self.$recording.fractionalLeq).padding(10)
    }
  }
}
// The view when recording a new clip
struct RecorderView: View {
  @ObservedObject var recorder : Recorder

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
          RecordButton()
/*
          Text("Re-record").foregroundColor(Color.black)
           .frame(width: g.size.width - 40)
            .padding(EdgeInsets.init(top: 20, leading: 0, bottom: 20, trailing: 0))
            .background( Color.red)
*/            .onTapGesture {
              self.recorder.startRecordingSample()
              // self.recorder.objectWillChange.send()
          }
        }

        //        .layoutPriority(0.1)

        MapView(centerCoordinate: .constant(self.recorder.myLocation!.coordinate)).layoutPriority(0.2)
          .padding(20)

        OnAirView(recording: self.recorder.recording)



        MyProgressBar(value: self.recorder.percentage).layoutPriority(0)
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

struct RecorderView_Previews: PreviewProvider {
  static var previews: some View {
    /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
  }
}
