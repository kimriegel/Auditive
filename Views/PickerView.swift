// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct PickerView<T : MyEnum>: View {
  var label : String

//  var picks : [String]

//  @Binding var pick : Int
  @Binding var pick : OrOther<T>

//  var maximumRating = 6
  var offImage = Image(systemName: "circle")
  var onImage = Image(systemName: "circle.fill")

  var offColor = Color.gray
  var onColor = Color.yellow

  func image(for number: Int) -> Image {
    if pick.choiceIndex == number /* number == pick */ {
      return onImage // ?? onImage
    } else {
      return offImage
    }
  }

  let smallSize = CGFloat(11.5)

  var body: some View {
    VStack {
      if label.isEmpty == false {
        Text(label)
      }

      HStack {
//        Text("Disagree").font(.system(size: smallSize))
        ForEach(0..<T.allCases.count) { number in
          VStack(spacing: 1) {
          self.image(for: number)
            .foregroundColor(number == self.pick.choiceIndex ? self.onColor : self.offColor)
            .onTapGesture {
              self.pick.choice = T.allCases[number as! T.AllCases.Index]
            }
            .padding(EdgeInsets.init(top: 0, leading: 4, bottom: 0, trailing: 4))
            Text(T.allCases[ number as! T.AllCases.Index ].description).font(.system(size: smallSize))
          }
        }
      }.padding([.top], 3)
    }.padding([.top, .bottom], 3)
  }
}

struct PickerView_Previews: PreviewProvider {
  static var previews: some View {
    PickerView(label: "How often do you?", pick: .constant(OrOther<Occasionality>(choice: .sometimes))) // , picks : ["Never", "Sometimes", "Always"])
  }
}
