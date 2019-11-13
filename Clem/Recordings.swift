
//  Created by Robert M. Lefkowitz on 4/13/19.

import AVFoundation
import os

class Recordings {

  var microphone : Microphone = Microphone()

  var recordings : [Recording] {
    get {
      microphone.listOfRecordings()
    }
  }
  var recordingNames : [String] {
    get {
      microphone.listOfRecordings().map {
        $0.displayName
      }
    }
  }

  var dataObject: String = ""
  var audioPlayer : AVAudioPlayer?

  func startRecordingSample() {
    // FIXME:  If I hit the record button and then again before the first recording finishes,
    // it crashes
    // reason: 'Invalid update: invalid number of rows in section 0. The number of rows contained in an existing section after the update (5) must be equal to the number of rows contained in that section before the update (5), plus or minus the number of rows inserted or deleted from that section (1 inserted, 0 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).
    
    
    microphone.checkPermission()
    print("recording");
    microphone.startStreaming { url in
     // self.recordingList.insert(url, at: 0)
     // DispatchQueue.main.async { self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top) }
      // DispatchQueue.main.async { self.tableView.reloadData(); }
    }
    print("done")
  }
 

  func deleteRecording(_ n : Int) {
    let u = microphone.listOfRecordings()[n]
    u.delete()
  }

  // =========================

  
  func playSelected(_ n : Int) {

    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)

      audioPlayer = try AVAudioPlayer(contentsOf: microphone.listOfRecordings()[n].url, fileTypeHint: AVFileType.aiff.rawValue)
      DispatchQueue.main.async {
      self.audioPlayer?.play()
      }
    } catch let error {
      print("Can't play the audio file failed with an error \(error.localizedDescription)")
    }


  }

}
