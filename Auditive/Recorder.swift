
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import AVKit
import AVFoundation
import CloudKit
import os

class Recorder: NSObject, ObservableObject {
  @Published var onAir : Bool = false
  @Published var percentage : CGFloat = 0
  @Published var recording : Recording = Recording()

  var timer : Timer?

  var baseTime : Double? = nil

  var recordings : [Recording] {
    get {
      listOfRecordings()
    }
  }
  var recordingNames : [String] {
    get {
      listOfRecordings().map {
        $0.displayName
      }
    }
  }
  

  static let recordingLength = 20 // seconds for a recording

  private var permissionGranted = false
  private var frameCount : Int = 0
  private var counter : Int = 0 // number of captured frames
  private var arec : AVAudioRecorder!
  private var musicQ : DispatchQueue = DispatchQueue.init(label: "musicGrabber", attributes: [])
  var myLocation : CLLocation?
  
  override init() {
    locationManager = CLLocationManager()
    super.init()
    checkPermission()
    startLocationTracking()
  }

  func checkPermission() {
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

  private func requestPermission() {
    // sessionQueue.suspend()
    AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
      self.permissionGranted = granted
      // self.sessionQueue.resume()
    }
  }
  
  func listOfRecordings() -> [Recording] {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    do {
      let paths = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
      let ps = paths.sorted {  $0.lastPathComponent > $1.lastPathComponent }
      return ps.map { Recording($0) }
    } catch {
      print("getting list of paths", error)
    }
    return []
  }

  var locationManager : CLLocationManager

  // Upload the contents of the URL to cloudkit
  func upload(_ url : URL) {
    let sid = CKRecord.ID(recordName: "??")
    let rec = CKRecord(recordType: "Samples", recordID: sid)

    // CLLocation , CLGeoCoder
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

extension Recorder : CLLocationManagerDelegate {
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
      myLocation = location
      let eventDate = location.timestamp;
      let howRecent = eventDate.timeIntervalSinceNow
      if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        os_log("latitude %+.6f, longitude %+.6f\n", type: .info,
               location.coordinate.latitude,
               location.coordinate.longitude);
      }
    }
  }

  @discardableResult func startRecordingSample() -> Recording {
    // FIXME:  If I hit the record button and then again before the first recording finishes,
    // it crashes
    // reason: 'Invalid update: invalid number of rows in section 0. The number of rows contained in an existing section after the update (5) must be equal to the number of rows contained in that section before the update (5), plus or minus the number of rows inserted or deleted from that section (1 inserted, 0 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).


    checkPermission()
    print("recording");

    let rr = Recording()
    self.onAir = true
    self.recording = rr
    self.recording.location = self.myLocation
    rr.recorder = self

    rr.record(length: DispatchTimeInterval.seconds(Self.recordingLength)) {
      self.onAir = false
      self.timer?.invalidate()
      self.percentage = 0
      rr.fractionalLeq = 0
      rr.recorder = nil
    }

    return rr
  }

  func stop() {
    self.recording.stop()
    self.onAir = false
    self.baseTime = nil
    self.timer?.invalidate()
    self.percentage = 0
    self.recording.fractionalLeq = 0
  }
}
