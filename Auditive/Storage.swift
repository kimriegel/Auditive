//// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import CoreLocation
import os

func uploadConsent() {
  // FIXME: not yet implemented
  UserDefaults.standard.set( true, forKey: Key.hasConsented)

  do {
    let dat = Data()
    var tags = [String : String]()

    if let uid = UserDefaults.standard.string(forKey: Key.UserRecordName) {
      tags[Key.UserRecordName] = uid
    }
    guard let vid = UserDefaults.standard.string(forKey: Key.VendorID) else {
      os_log("failed to upload consent because did not have VendorID", type: .error)
      // FIXME: What do I do here?  Consent failed to upload
      return
    }
    let _ = try
      S3(bucket: Key.s3bucket)?.putObject("consent-\(vid)", dat, metadata: tags)
    os_log("saved consent", type: .info)
  } catch(let e) {
    os_log("failed to save consent: %s", type: .error, e.localizedDescription)
  }
}

func saveSurvey(_ survey : Survey) {
  let j = try? String(data: JSONEncoder().encode(survey), encoding: .utf8)
  UserDefaults.standard.set(j, forKey: Key.healthSurvey)

  guard let vid = UserDefaults.standard.string(forKey: Key.VendorID)
  else {
    os_log("unable to get vendor ID %s", type: .error, #function)
    return
  }

  var tags = [String : String]()
  if let uid = UserDefaults.standard.string(forKey: Key.UserRecordName) {
    tags[Key.UserRecordName] = uid
  }
  tags[Key.VendorID] = vid
  
  do {
    let dat = try JSONEncoder().encode(survey)
    let _ = try
      S3(bucket: Key.s3bucket)?.putObject("healthSurvey-\(vid)", dat, metadata: tags)
    os_log("saved survey")
  } catch(let e) {
    os_log("failed to save survey: %s", type: .error, e.localizedDescription)
  }
}

func uploadToS3(url : URL, location: CLLocation?, annoyance: Annoyance) {
  do {
    let dat = try Data.init(contentsOf: url)

    var tags = [String:String]()
    if let l = location {
      tags[Key.latitude]=String(l.coordinate.latitude)
      tags[Key.longitude]=String( l.coordinate.longitude)
      tags[Key.altitude]=String(l.altitude)
      let dateFormatter : DateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      tags[Key.timestamp]=dateFormatter.string(from: l.timestamp)
      if let ss = String.init(data: try JSONEncoder().encode(annoyance), encoding: .utf8) {
        tags[Key.annoyance]=ss
      }
    }
    let _ = try
      S3(bucket: Key.s3bucket)?.putObject(url.lastPathComponent, dat, metadata: tags)
    os_log("uploaded audio", type: .info)
  } catch(let e) {
    os_log("failed to upload audio: %s", type: .error, e.localizedDescription)
  }
}
