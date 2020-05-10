
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CloudKit

func getSecret() -> (String, String, String)? {
  let c : CKContainer = CKContainer(identifier: "iCloud.edu.qcc.quacc.Auditive")
  let pd = c.publicCloudDatabase
  let id = CKRecord.ID.init(recordName: "ONE")
  var res : (String, String, String)?
  let sem = DispatchSemaphore(value: 0)
  pd.fetch(withRecordID: id) { (rec, err) in
    if let e = err {
      print("failed to get AWS secret", e.localizedDescription)
      return
    }
    guard let rec = rec else {
      print("failed to get AWS record")
      return
    }
    res = (rec["access"] as! String, rec["secret"] as! String, rec["region"] as! String)
    sem.signal()
  }
  let _ = sem.wait(wallTimeout: DispatchWallTime.now()+DispatchTimeInterval.seconds(2))
  return res
}
