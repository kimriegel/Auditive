// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct PerceptionView : View {
  @Binding var noise : Noise

  var body: some View {
    Form {
      Section(header: Text("Noise Perception")) {
        RatingView(rating: $noise.perceptionNoise.frustration, label: "I get frustrated when exposed to loud noise:", maximumRating: 5)
        RatingView(rating: $noise.perceptionNoise.awoken, label: "I am easily awoken by noise", maximumRating: 5)
        RatingView(rating: $noise.perceptionNoise.music, label: "I enjoy listening to loud music", maximumRating: 5)
        RatingView(rating: $noise.perceptionNoise.relax, label: "I find it hard to relax in a noisy place", maximumRating: 5)
        RatingView(rating: $noise.perceptionNoise.exposure, label: "I am exposed to a lot of noise in my daily life", maximumRating: 5)
      }
    }
  }
}

struct NoiseView : View {
  @Binding var noise : Noise

  var part : Int

  var body: some View {

    if part == 1 {
      Form {
        Section(header: Text("Home Noise Environment")) {
          RatingView(rating: $noise.homeNoise.noisy , label: "The noise level in my community is high:",
                     maximumRating: 5).padding([.bottom, .top], 12)
          PickerView(label: "I have lived in my current home or apartment", pick: self.$noise.homeNoise.living).padding([.bottom, .top], 12)
          PickerView(label: "Noise affects my sleep", pick: self.$noise.homeNoise.sleep).padding([.bottom, .top], 12)
          PickerView(label: "On a normal day, I listen or watch digital devices", pick: self.$noise.homeNoise.digital /*, allowOther: false*/ ).padding([.bottom, .top], 12)
        }
      }
    } else if part == 2 {
      Form {
        Section(header: Text("Work Environment")) {
          RatingView(rating: $noise.workNoise.noisy, label: "I work in a noisy environment", maximumRating: 5)
          PickerView(label: "I wear ear covering or ear plugs while working", pick: self.$noise.workNoise.earPlugs)

          // XPick(label: "I wear ear covering or ear plugs while working", pick: self.$noise.workNoise.earPlugs, allowOther: false)
          // XPick(label: "How often did you ride/operate motorized vehicles such as motorcycles, trucks, cars or trains", pick: self.$noise.workNoise.vehicles, allowOther: false)
          PickerView(label: "I ride/operate motorized vehicles such as motorcycles, trucks, cars or trains", pick: self.$noise.workNoise.vehicles)
        }
      }
    }
  }
}

/*struct NoiseView_Previews: PreviewProvider {
 static var previews: some View {
 NoiseView()
 }
 }
 */
