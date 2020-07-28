
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import AVKit
import AVFoundation
import CloudKit
import os

class Recorder: NSObject, ObservableObject {
  @Published var recording : Recording = Recording()

  var timer : Timer?


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


}

