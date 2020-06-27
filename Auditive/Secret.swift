
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CloudKit
import os

func getSecret(_ key : String) -> (String, String, String)? {
  let c : CKContainer = CKContainer.default() // (identifier: "iCloud.edu.qcc.quacc.Auditive")
  let pd = c.publicCloudDatabase
  let id = CKRecord.ID.init(recordName: key)
  var res : (String, String, String)?
  let sem = DispatchSemaphore(value: 0)
  pd.fetch(withRecordID: id) { (rec, err) in
    if let e = err {
      os_log("failed to get AWS secret %", type: .error, e.localizedDescription)
      return
    }
    guard let rec = rec else {
      os_log("failed to get AWS record")
      return
    }
    res = (rec["access"] as! String, rec["secret"] as! String, rec["region"] as! String)
    sem.signal()
  }
  let _ = sem.wait(wallTimeout: DispatchWallTime.now()+DispatchTimeInterval.seconds(2))
  return res
}
