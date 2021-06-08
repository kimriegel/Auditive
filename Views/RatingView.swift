// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import Combine

typealias Rater = RateView

struct RateView: View {
  @Binding var rating: Int
  var label = ""
  var maximumRating : Int = 6
  @State var ratingString = ""
  @State var ratingState : Float

  init(rating r: Binding<Int>, label l : String, maximumRating x : Int = 6) {
    _rating = r
    _ratingState = State(initialValue: Float(r.wrappedValue))
    label = l
    maximumRating = x
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(label)
      HStack {
        Slider.init(value: $ratingState,
                    in: 0...Float(maximumRating), step: 1 ) { z in
          if (!z) {
            rating = Int(ratingState)
          }
          // self.ratingString = "\(self.rating)/\(self.maximumRating)"
        }
        Text("\(ratingState == 0 ? "?" : String(describing: Int(ratingState)))/\(self.maximumRating)")
      } // .offset(y: -10)
      .padding(.top, -10)
      .padding([.leading,.trailing], 10)
    }.onReceive(Just(rating)) { z in
      self.ratingString = "\(self.rating == 0 ? "?" : String(describing: self.rating))/\(self.maximumRating)"
      // print("received \(rating) \(z)")
    }
  }
}

struct RatingView: View {
  @Binding var rating : Int
  
  var label = ""
  var maximumRating = 6
  var offImage = Image(systemName: "circle")
  var onImage = Image(systemName: "circle.fill")
  
  var offColor = Color.gray
  var onColor = Color.yellow
  
  func image(for number: Int) -> Image {
    if number > rating {
      return offImage // ?? onImage
    } else {
      return onImage
    }
  }

  let smallSize = CGFloat(11.5)

  var body: some View {
    VStack {
      if label.isEmpty == false {
        Text(label)
      }
      HStack {
        Text("Disagree").font(.system(size: smallSize))
        ForEach(1..<maximumRating+1) { number in
          self.image(for: number)
            .foregroundColor(number > self.rating ? self.offColor : self.onColor)
            .onTapGesture {
              self.rating = number
            }
            .padding(EdgeInsets.init(top: 0, leading: 4, bottom: 0, trailing: 4))
        }
                Text("Agree").font(.system(size: smallSize))
      }.padding([.top], 3)
    }.padding([.top, .bottom], 3)
  }
}

struct RatingView_Previews: PreviewProvider {
  static var previews: some View {
    RatingView(rating: .constant(4))
  }
}
