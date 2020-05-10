//
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import Network

func monitorNetwork() {
  let monitor = NWPathMonitor()

  monitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
      print("We're connected!")
    } else {
      print("No connection.")
    }

    print(path.debugDescription)
    print(path.availableInterfaces)
    print(path.isExpensive)
  }

  let queue = DispatchQueue(label: "Monitor")
  monitor.start(queue: queue)
}
