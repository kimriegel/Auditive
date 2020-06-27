
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import AVFoundation
import os
import CoreLocation
import Foundation

class Recording : NSObject, Identifiable, ObservableObject {
  static func == (lhs: Recording, rhs: Recording) -> Bool {
    lhs.displayName == rhs.displayName
  }
  
  let url : URL
  let id : String
  var timer : Timer?

  @Published var avgSamples : [Float] = [0]
  @Published var peakSamples : [Float] = [0]

  var location : CLLocation?

  static var mediaDir : URL {
    get {
      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
  }

  let aa : AVAudioSession = AVAudioSession.sharedInstance()
  var ap : AVAudioPlayer! = nil
  var arec : AVAudioRecorder?

  override init() {
    let path = Self.mediaDir
    let dateFormatter : DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let time = dateFormatter.string(from: Date())
    url = path.appendingPathComponent("audio-\(time)").appendingPathExtension("aiff")
    id = url.lastPathComponent
    super.init()
  }
  
  init(_ u : URL) {
    url = u
    id = u.lastPathComponent
    if let ll = try? XAttr(u).get(forName: "location"),
      let zz = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(ll) as? CLLocation {
        self.location = zz
    }
    super.init()
  }
  
  var displayName : String {
    get {
      url.lastPathComponent
    }
  }

  static var recordings : [Recording] {
    get {
      listOfRecordings()
    }
  }
  static var recordingNames : [String] {
    get {
      listOfRecordings().map {
        $0.displayName
      }
    }
  }

  class func listOfRecordings() -> [Recording] {
    let path = mediaDir
    do {
      let paths = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
      let ps = paths.sorted {  $0.lastPathComponent > $1.lastPathComponent }
      return ps.compactMap {
        if ($0.pathExtension == "aiff") {
          return Recording($0)
        } else {
          return nil
        }
      }
    } catch {
      print("getting list of paths", error)
    }
    return []
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


  func stop() {
    arec?.stop()
    // self.delete()
  }

  func record(length clipLength: DispatchTimeInterval, everyTick : @escaping () -> Void,  _ f : @escaping () -> Void ) {
    do {
      try self.aa.setCategory(.record, mode: .default)
      try self.aa.setActive(true)
    } catch (let e ) {
      print("failed to set up audio session \(e.localizedDescription)")
      f()
      return
    }

    let recordSettings : [String:Any] = [
      AVFormatIDKey: kAudioFormatLinearPCM,
      AVNumberOfChannelsKey : aa.inputNumberOfChannels,
      AVSampleRateKey : aa.sampleRate
    ]

    do {
      try arec = AVAudioRecorder(url: url, settings: recordSettings)
      arec?.isMeteringEnabled = true
      let chans = arec?.channelAssignments?.count ?? 1

      avgSamples = Array(repeating: Float(0), count: chans)
      peakSamples = Array(repeating: Float(0), count: chans)

      arec?.record()

      self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        if let a = self.arec {
          a.updateMeters()
        for i in 0..<chans {
          self.peakSamples[i] = 1 - (a.peakPower(forChannel: i) / -53)
          self.avgSamples[i] = 1 - (a.averagePower(forChannel: i) / -53)
          print(self.avgSamples[i], a.averagePower(forChannel: i))
        }
        }
        everyTick()
      }

      DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now()+clipLength) {
        self.timer?.invalidate()
        self.arec?.stop()
        f()
        // print(self.arec?.url,self.arec?.deviceCurrentTime, self.arec?.currentTime)
        self.arec = nil


        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.outputFormat = .binary
        archiver.encode(self.location, forKey: NSKeyedArchiveRootObjectKey)
        archiver.finishEncoding()
        let lld = archiver.encodedData
        try? XAttr(self.url).set(data: lld, forName: "location")
      }
    } catch let e {
      f()
      os_log("%s", type:.debug, "audioEngine start: \(e.localizedDescription)")
      return
    }
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

/*
class MyLocation : CLLocation, Codable {
  enum CodingKeys: String, CodingKey {
    case latitude
    case longitude
    case altitude
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(coordinate.latitude, forKey: .latitude)
    try container.encode(coordinate.longitude, forKey: .longitude)
    try container.encode(self.altitude, forKey: .altitude)
  }

  required public init(from decoder : Decoder) throws {
    super.init()
  }

  required public init(coder : NSCoder) {
    super.init()
  }
}
*/

extension Recording : AVAudioRecorderDelegate {
  func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    print("finished recording \(self.url.path)")
  }
}

extension Recording : AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ p : AVAudioPlayer, successfully: Bool) {
    print("finished playing \(self.url.path)")
  }
}
