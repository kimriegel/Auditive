//
//  Recording.swift
//  Clem
//
//  Created by Robert Lefkowitz on 11/12/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

import AVFoundation
import os

class Recording : NSObject, Identifiable {
  static func == (lhs: Recording, rhs: Recording) -> Bool {
    lhs.displayName == rhs.displayName
  }
  
  let url : URL
  let id : String
  
  
  let aa : AVAudioSession = AVAudioSession.sharedInstance()
  var ap : AVAudioPlayer! = nil
  var arec : AVAudioRecorder! = nil

  override init() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.string(from: Date())
        url = path.appendingPathComponent("s-\(time)").appendingPathExtension("aiff")
      id = url.lastPathComponent
    super.init()
    
  }
  
  init(_ u : URL) {
    url = u
    id = u.lastPathComponent
/*    do {
      let z = try u.resourceValues(forKeys: [URLResourceKey.documentIdentifierKey, .fileResourceIdentifierKey])
      let y = z.fileResourceIdentifier
      print(y)
    } catch (let e) {
      print("getting recording info: \(e.localizedDescription)")
    }
 */
    super.init()
  }
  
  var displayName : String {
    get {
      url.lastPathComponent
    }
  }
  
  func delete() {
    
      do {
        try FileManager.default.removeItem(at: url)
      } catch {
        os_log("deleting: %s", type: .error, error.localizedDescription)
      }
    
  }
  
  func play() {
    do {
      try self.aa.setCategory(.playback, mode: .default)
      try self.aa.setActive(true)

      self.ap = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.aiff.rawValue)
      self.ap.delegate = self
      DispatchQueue.main.async {
        print("playing")
        
        self.ap.play()
      }
    } catch let error {
      print("Can't play the audio file failed with an error \(error.localizedDescription)")
    }


  }

  
  func record(_ f : @escaping () -> Void ) {
    
    do {
      
        try self.aa.setCategory(.record, mode: .default)
    try self.aa.setActive(true)
    } catch (let e ) {
      print("failed to set up audio session \(e.localizedDescription)")
      f()
      return
    }

        let recordSettings : [String:Any] = [
          // AVFormatIDKey: kAudioFormatAppleLossless,
          AVFormatIDKey: kAudioFormatLinearPCM,
          // AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
          // AVEncoderBitRateKey : 320000,
          AVNumberOfChannelsKey : aa.inputNumberOfChannels,
          // AVChannelLayoutKey : iff.channelLayout as Any,
          AVSampleRateKey : aa.sampleRate
        ]

         let clipLength = 10
        do {
    //      try afile = AVAudioFile.init(forWriting: url, settings: recordSettings)
            
          try arec = AVAudioRecorder(url: url, settings: recordSettings)
 //         try audioEngine!.start()
          arec.record()

          DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now()+DispatchTimeInterval.seconds(clipLength)) {
            // self.audioEngine!.stop()
            self.arec.stop()
//            onCompletion(self.arec.url)
            f()
            print(self.arec.url,self.arec.deviceCurrentTime, self.arec.currentTime)
            self.arec = nil
          }

        } catch let e {
          f()
          os_log("%s", type:.debug, "audioEngine start: \(e.localizedDescription)")
          return
        }
  //  f()
  }
  
  var leq : Double { get {
    do {
      return try Double(LeqMaster(url))
    } catch (let e) {
      print("getting leq \(e.localizedDescription)")
    }
    return 0
  }
  }
}


extension Recording : AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ p : AVAudioPlayer, successfully: Bool) {
    print("finished playing \(self.url.path)")
  }
}
