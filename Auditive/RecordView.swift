
//  Created by Robert Lefkowitz on 10/23/19.

import SwiftUI

struct RecordView: View {
    var body: some View {
      VStack() {
        Button(action: {
          print("record")
        }) {
          Text("Record")
            .font(.system(size: 40))
            .padding(EdgeInsets.init(top: 10, leading: 50, bottom: 10, trailing: 50))
        }
      .padding()
        .background(Color(red: 0.67, green: 0.67, blue: 0.67 ))
      .cornerRadius(10)
    }
  }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
