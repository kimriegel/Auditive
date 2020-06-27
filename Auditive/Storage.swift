//// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import CoreLocation

func uploadConsent() {
  // FIXME: not yet implemented
  UserDefaults.standard.set( true, forKey: Key.hasConsented)
  print("\(#function) Not yet implemented")
}

func saveSurvey(_ survey : Survey) {
  let j = try? String(data: JSONEncoder().encode(survey), encoding: .utf8)
  UserDefaults.standard.set(j, forKey: Key.healthSurvey)

  // FIXME: not yet implemented
  print("\(#function) Not yet implemented")
}

func uploadToS3(url : URL, location: CLLocation?) {
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
    }
  let a = try
    S3(bucket: Key.s3bucket)?.putObject(url.lastPathComponent, dat, metadata: tags)
  } catch(let e) {
    print("saving to S3 \(e.localizedDescription)")
  }
}
