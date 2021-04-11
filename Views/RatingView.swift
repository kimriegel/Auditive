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

  var body: some View {
    Group {
      Text(label)
      HStack {
        Slider(value: Binding(get: {
//          self.ratingString = String(describing: self.rating)
          return Float(self.rating)
        }, set: {
          // print("-> \($0)")
          self.rating = Int($0)
          self.ratingString = "\(Int($0))/\(self.maximumRating)"
        }
        ), in: 1...Float(maximumRating), step: 1 ) { z in
          // self.ratingString = "\(self.rating)/\(self.maximumRating)"
        }
        Text( ratingString )
      } // .offset(y: -10)
      .padding(.top, -10)
      .padding([.leading,.trailing], 10)
    }.onReceive(Just(rating)) { z in
      self.ratingString = "\(self.rating)/\(self.maximumRating)"
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
  
  var body: some View {
    VStack {
      if label.isEmpty == false {
        Text(label)
      }
      HStack {
        ForEach(1..<maximumRating+1) { number in
          self.image(for: number)
            .foregroundColor(number > self.rating ? self.offColor : self.onColor)
            .onTapGesture {
              self.rating = number
            }
            .padding(EdgeInsets.init(top: 0, leading: 4, bottom: 0, trailing: 4))
        }
      }
    }
  }
}

struct RatingView_Previews: PreviewProvider {
  static var previews: some View {
    RatingView(rating: .constant(4))
  }
}
