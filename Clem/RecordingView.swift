//
//  RecordingView.swift
//  Clem
//
//  Created by Robert Lefkowitz on 11/13/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

import SwiftUI

struct RecordingView: View {
  let recording : Recording
    var body: some View {
        VStack {
          Text(recording.displayName)
                .font(.largeTitle)
          HStack {
            Text("Leq:")
            Text(String(describing: recording.leq))
          }
        }
  }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
      RecordingView(recording: Recording(URL(string: "https://example.com")!))
    }
}
