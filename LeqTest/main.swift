//
//  main.swift
//  LeqTest
//
//  Created by Robert Lefkowitz on 10/22/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

import Foundation

let file = "file:///Users/r0ml/Repositories/Auditive/Resources/rpgad.wav"
let u = URL(string: file)!

do {
  let z = try LeqMaster(u)
  print(z)
  
  let y = try LeqCalibration(u)
  print(y)
  
} catch {
  print(error)
}

