//
//  Observable.swift
//  Clem
//
//  Created by Robert Lefkowitz on 11/12/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

import Foundation

class Observable<T> : ObservableObject {
  var f : ((T) -> Void)?
  
  @Published var x : T {
    didSet {
      if let f = f { f(x) }
      objectWillChange.send()
    }
  }
  
  init( _ y : T, f : ((T) -> Void)? = nil ) {
    x = y
    self.f = f
  }
}
