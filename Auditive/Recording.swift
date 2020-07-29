
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import AVFoundation
import os
import CoreLocation
import Foundation
import Combine
import CloudKit

class Recording : NSObject, Identifiable, ObservableObject {
  static func == (lhs: Recording, rhs: Recording) -> Bool {
    lhs.displayName == rhs.displayName
  }
  
  var url : URL
  var id : String
  var timer : Timer?

  @Published var annoyance = Annoyance()
  @Published var fractionalLeq : Float = 0

  var location : CLLocation?
  var locationManager : CLLocationManager

  static let recordingLength = 5 // seconds for a recording

  @Published var isRecording : Bool = false
  @Published var percentage : CGFloat = 0
  @Published var isPlaying : Bool = false

  var baseTime : Double? = nil

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
    locationManager = CLLocationManager()
    Self.checkPermission()


    let path = Self.mediaDir
    let dateFormatter : DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let time = dateFormatter.string(from: Date())
    url = path.appendingPathComponent("audio-\(time)").appendingPathExtension("aiff")
    id = url.lastPathComponent

    super.init()
    startLocationTracking()
    sink = $annoyance.sink {
      if let a = try? JSONEncoder().encode($0) {
        try? XAttr(self.url).set(data: a, forName: Key.annoyance)
      }
    }
  }
  
  convenience init(_ u : URL) {
    self.init()
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
      recordings.map {
        $0.displayName
      }
    }
  }

  func delete() {
    
    do {
      try FileManager.default.removeItem(at: url)
      NotificationCenter.default.post(Notification(name: .deletedFile))
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
        self.ap?.play()
        self.isPlaying = true
      }
    } catch let error {
      os_log("Playing audio file failed: %s", type: .error, error.localizedDescription)
    }
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
      if self.baseTime == nil {
        self.baseTime = dd
      }

      let jj = dd - (self.baseTime ?? dd )
      self.percentage = CGFloat(jj / Double(Self.recordingLength) )
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
//    print("finished playing \(self.url.path)")
    self.isPlaying = false
  }
}

var permissionGranted : Bool = false

extension Recording {
  static func checkPermission() {
    switch AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) {
    case .authorized:
      permissionGranted = true
    case .notDetermined:
      requestPermission()
    case .denied:
      os_log("%s", type: .error, "**** can't use the microphone!!!");
    case .restricted:
      os_log("%s", type: .error, "*** restricted microphone use!!!");
    default:
      permissionGranted = false
    }
  }

  static private func requestPermission() {
    AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
      permissionGranted = granted
    }
  }

  static func listOfRecordings() -> [Recording] {
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

  func startRecordingSample() {
    // FIXME:  If I hit the record button and then again before the first recording finishes,
    // it crashes
    // reason: 'Invalid update: invalid number of rows in section 0. The number of rows contained in an existing section after the update (5) must be equal to the number of rows contained in that section before the update (5), plus or minus the number of rows inserted or deleted from that section (1 inserted, 0 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).

    Self.checkPermission()

    self.isRecording = true
    self.record(length: DispatchTimeInterval.seconds(Self.recordingLength)) {
      self.isRecording = false
      self.timer?.invalidate()
      self.percentage = 0
      self.fractionalLeq = 0
    }
  }

  func stop() {
    audioFile = nil
    engine?.stop()
    self.isRecording = false
    self.baseTime = nil
    self.timer?.invalidate()
    self.percentage = 0
    self.fractionalLeq = 0
  }

  // Upload the contents of the URL to cloudkit
  func upload(_ url : URL) {
    let sid = CKRecord.ID(recordName: "??")
    let rec = CKRecord(recordType: "Samples", recordID: sid)

    rec["location"] = "unimplemented" as NSString
    rec["time"] = Date()
    let asset = CKAsset(fileURL: url)
    rec["image"] = asset

    let container = CKContainer.default()
    let pubdb = container.publicCloudDatabase
    pubdb.save(rec) { (record, error) in
      if let error = error {
        os_log("saving sample to cloud: %s", type: .error, error.localizedDescription)
      }
      os_log("saved successfully", type: .info)
    }
  }

}

extension Recording : CLLocationManagerDelegate {
  func startLocationTracking() {
    if (CLLocationManager.locationServicesEnabled()) {
      locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
      locationManager.distanceFilter = 100 // meters
      locationManager.startUpdatingLocation()
    } else {
      os_log("location services not enabled!", type: .info)
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      self.location = location
      let eventDate = location.timestamp;
      let howRecent = eventDate.timeIntervalSinceNow
      if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        // os_log("latitude %+.6f, longitude %+.6f\n", type: .info, location.coordinate.latitude, location.coordinate.longitude);
      }
    }
  }

}
