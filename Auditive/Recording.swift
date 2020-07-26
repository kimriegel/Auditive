
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import AVFoundation
import os
import CoreLocation
import Foundation
import Combine

class Recording : NSObject, Identifiable, ObservableObject {
  static func == (lhs: Recording, rhs: Recording) -> Bool {
    lhs.displayName == rhs.displayName
  }
  
  let url : URL
  let id : String
  var timer : Timer?

  @Published var annoyance = Annoyance()
  @Published var fractionalLeq : Float = 0

  var recorder : Recorder?

  var location : CLLocation?

  static var mediaDir : URL {
    get {
      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
  }

  let aa : AVAudioSession = AVAudioSession.sharedInstance()
  var ap : AVAudioPlayer? = nil
  var engine : AVAudioEngine?
  var sink : AnyCancellable!

  var noiseQ : DispatchQueue = DispatchQueue.init(label: "audioGrabber", attributes: .concurrent)
  var counter = 0
  var audioFile : AVAudioFile!

  override init() {
    let path = Self.mediaDir
    let dateFormatter : DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let time = dateFormatter.string(from: Date())
    url = path.appendingPathComponent("audio-\(time)").appendingPathExtension("aiff")
    id = url.lastPathComponent

    super.init()
    sink = $annoyance.sink {
      if let a = try? JSONEncoder().encode($0) {
        try? XAttr(self.url).set(data: a, forName: Key.annoyance)
      }
    }
  }
  
  init(_ u : URL) {
    url = u
    id = u.lastPathComponent
    if let ll = try? XAttr(u).get(forName: Key.location),
       let zz = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(ll) as? CLLocation {
      self.location = zz
    }
    if let aa = try? XAttr(u).get(forName: Key.annoyance),
       let zz = try? JSONDecoder().decode(Annoyance.self, from: aa) {
      self.annoyance = zz
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
      self.ap?.delegate = self

      DispatchQueue.main.async {
        print("playing")
        self.ap?.play()
      }
    } catch let error {
      print("Can't play the audio file failed with an error \(error.localizedDescription)")
    }
  }

  func stop() {
    audioFile = nil
    engine?.stop()
  }

  func captured(thisBuf: AVAudioPCMBuffer, timex: AVAudioTime) {
    counter += 1

    // let tsr = timex.sampleRate / 60  // this should be number of samples I want per 1/60 second frame.
    guard let _ = thisBuf.floatChannelData else {
      os_log("%s", type:.error, "didn't have floatChannelData")
      return
    }

    noiseQ.sync(flags: .barrier) {

      do {
        if let a = audioFile {
          try a.write(from: thisBuf)
        }
      } catch(let e) {
        os_log("writing to audio file: %s", type: .error, e.localizedDescription)
      }

    }
    let z = Leq(thisBuf)
    DispatchQueue.main.async {
      self.fractionalLeq = z
      let dd = Double(timex.sampleTime) / timex.sampleRate
      if self.recorder?.baseTime == nil {
        self.recorder?.baseTime = dd
      }

      let jj = dd - (self.recorder?.baseTime ?? dd )
      self.recorder?.percentage = CGFloat(jj / Double(Recorder.recordingLength) )
      self.recorder?.objectWillChange.send()
    }
  }


  func record(length clipLength: DispatchTimeInterval,  _ f : @escaping () -> Void ) {
    do {
      try self.aa.setCategory(.record, mode: .default)
      try self.aa.setActive(true)
    } catch (let e ) {
      print("failed to set up audio session \(e.localizedDescription)")
      f()
      return
    }

    do {

      try AVAudioSession.sharedInstance().setCategory(.record)

      engine = AVAudioEngine()

      let inputNode = engine!.inputNode
      let sr = inputNode.inputFormat(forBus: 0).sampleRate
      let bus = 0

      let fc = sr / 10.0

      audioFile = try AVAudioFile(forWriting: url, settings: engine!.inputNode.outputFormat(forBus: bus).settings)

      inputNode.installTap(onBus: bus, bufferSize: AVAudioFrameCount(fc), format: inputNode.inputFormat(forBus: bus), block: self.captured )

      engine?.prepare()
      try engine?.start()

      DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now()+clipLength) {
        self.timer?.invalidate()
        self.audioFile = nil

        self.engine?.stop()
        f()
        // print(self.arec?.url,self.arec?.deviceCurrentTime, self.arec?.currentTime)
        self.engine = nil


        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.outputFormat = .binary
        archiver.encode(self.location, forKey: NSKeyedArchiveRootObjectKey)
        archiver.finishEncoding()
        let lld = archiver.encodedData
        try? XAttr(self.url).set(data: lld, forName: Key.location)
      }
    } catch let e {
      f()
      os_log("%s", type:.error, "audioEngine start: \(e.localizedDescription)")
      return
    }
  }
  
  var leq : Double {
    get {
      if let _ = audioFile {
        return 0
      }
      do {
        return try Double(LeqMaster(url))
      } catch (let e) {
        print("getting leq \(e.localizedDescription)")
      }
      return 0
    }
  }
}

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
