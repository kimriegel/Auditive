//
//  Recording.swift
//  Clem
//
//  Created by Robert Lefkowitz on 11/12/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

import Foundation
import os

class Recording : NSObject, Identifiable {
  static func == (lhs: Recording, rhs: Recording) -> Bool {
    lhs.displayName == rhs.displayName
  }
  
  let url : URL
  let id : String
  
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
}
