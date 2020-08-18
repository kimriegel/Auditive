// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import UIKit
import CloudKit

extension Notification.Name {
  static var savedSurvey = Self("savedSurvey")
  static var savedConsent = Self("savedConsent")
  static var deletedFile = Self("deletedFile")
  static var addedFile = Self("addedFile")
  static var stoppedRecording = Self("stoppedRecording")
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
}

func stashIDs() {

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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    stashIDs()
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}

