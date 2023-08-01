
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import AVFoundation

public enum LeqError : Error {
  case runtimeError(String)
  case badURL(String)
  case badBuffer
}

public func LeqMaster(_ u : URL) throws -> Float {
  let avf = try AVAudioFile.init(forReading: u)
  guard let buf = AVAudioPCMBuffer.init(pcmFormat: avf.processingFormat, frameCapacity: AVAudioFrameCount(avf.length)) else { throw LeqError.badBuffer }
  try avf.read(into: buf )
  return Leq(buf)
}

public func Leq(_ buf : AVAudioPCMBuffer) -> Float {
  var tmsq : Float = 0
  let k : Float = 23047.0 / 32768
  var leqs : [Float] = []
  let rate = AVAudioFrameCount(buf.format.sampleRate / 10)

  // there are two channels?    buf.format.channelCount    and      buf.format.isInterleaved
  // this is channel 0
  let data = buf.floatChannelData![0]
  
  var msq : Float = 0
  
  for x in 0..<buf.frameLength {
    msq += pow((data[Int(x)])/k, 2)
    if (x % rate) == rate-1 {
      tmsq += msq
      if msq != 0 {
        leqs.append( 10*log10((msq/Float(rate))/pow(0.00002,2)) ) // # compute leq over 0.1 sec
      }
      msq = 0
    }
  }
  
  // let Lmax = leqs.reduce(-Float.greatestFiniteMagnitude) { max($0, $1) }
    return 10 * log10( (tmsq / Float(buf.frameLength)) / pow( 0.00002, 2))+22.8
}

// ======================================================================

public func LeqCalibration(_ u : URL) throws -> Float {
  let avf = try AVAudioFile.init(forReading: u)
  guard let buf = AVAudioPCMBuffer.init(pcmFormat: avf.processingFormat, frameCapacity: AVAudioFrameCount(avf.length)) else { throw LeqError.badBuffer }
  try avf.read(into: buf )

  // actual = 94 # known leq of sound for calibration
  let actual : Float = 94

  var minrun : [Float] = [1.0]
  var maxrun : [Float] = [50000.0]
  let give : Float = 0.1
  
  // there are two channels?    buf.format.channelCount    and      buf.format.isInterleaved
  // this is channel 0
  let data = buf.floatChannelData![0]

  var tleq : Float = 0
  var k : Float = 0
  
  while tleq < (actual - give) || tleq > (actual + give) { // #calibrate the file
    var tmsq : Float = 0
    k = Float( ( minrun.max()!+maxrun.min()! )/2 )

    // #compute new leq with updated k
    for i in 0..<Int(avf.length) {
      tmsq = tmsq + pow((data[i] * 32768)/k, 2)
    }
    tleq = 10*log10((tmsq/Float(avf.length))/pow(0.00002,2))

    if tleq < (actual - give) {
      maxrun.append(k)
    } else if tleq > (actual + give) {
      minrun.append(k)
    }
    print ("k, tleq",k, tleq)
  }

  print ("tleq",tleq)
  print ("k",k)
  return k
  
}
