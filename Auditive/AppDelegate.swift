// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import UIKit
import CloudKit

@main struct AuditiveApp : App {
  var body: some Scene {

    stashIDs();
    // FIXME: resetting for testing
     // UserDefaults.standard.removeObject(forKey: Key.healthSurvey)
     // UserDefaults.standard.removeObject(forKey: Key.hasConsented)

    return WindowGroup("Auditive") {
      // FIXME: This is for testing
        ContentView()
    }
  }
}

extension Notification.Name {
  static var deletedFile = Self("deletedFile")
  static var addedFile = Self("addedFile")
  static var stoppedRecording = Self("stoppedRecording")
  static var completedSurvey = Self("completedSurvey")
}

class Key {
  static var VendorID = "VendorID"
  static var UserRecordName = "UserRecordName"
  static var hasConsented = "hasConsented"
  static var healthSurvey = "healthSurvey"
  static var s3bucket = "edu-qcc-quaccs-auditive"
  static var latitude = "latitude"
  static var longitude = "longitude"
  static var altitude = "altitude"
  static var timestamp = "timestamp"
  static var annoyance = "annoyance"
  static var location = "location"
  static var savedSurvey = "savedSurvey"
}

func stashIDs() {
  print("stashing IDs")
  if nil == UserDefaults.standard.string(forKey: Key.VendorID) {
    if let ifv = UIDevice.current.identifierForVendor?.uuidString {
      UserDefaults.standard.set(ifv, forKey: Key.VendorID)
    } else {
      DispatchQueue.global().asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.milliseconds(800))) {
        stashIDs()
      }
      return
    }
  }

  if nil == UserDefaults.standard.string(forKey: Key.UserRecordName) {
    CKContainer.default().fetchUserRecordID {
      id, err in
      if let id = id {
        UserDefaults.standard.set(id.recordName, forKey: Key.UserRecordName)
      }
    }
  }
}
