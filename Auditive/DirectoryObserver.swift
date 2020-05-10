
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation

class DirectoryObserver {

    private let fileDescriptor: CInt
    private let source: DispatchSourceProtocol

    deinit {
      self.source.cancel()
      close(fileDescriptor)
    }

    init(URL: URL, f: @escaping ()->Void) {
      self.fileDescriptor = open(URL.path, O_EVTONLY)
      self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileDescriptor, eventMask: .all, queue: DispatchQueue.global())
      self.source.setEventHandler { f() }
      self.source.resume()
  }

}
