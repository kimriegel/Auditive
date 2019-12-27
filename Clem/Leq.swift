
//  Created by Robert Lefkowitz on 10/22/19.

import Foundation
import AVFoundation

public enum LeqError : Error {
  case runtimeError(String)
  case badURL(String)
  case badBuffer
}
// from the Python

// LeqMaster

/*
 import numpy as np
 import math
 
 from scipy.io import wavfile
 */

public func LeqMaster(_ u : URL) throws -> Float {
// fs, data = wavfile.read('AA_cal_wave')
  
  // guard let u = URL(string: file) else { throw LeqError.badURL(file) }
  let avf = try AVAudioFile.init(forReading: u)
  print(avf)
  
  guard let buf = AVAudioPCMBuffer.init(pcmFormat: avf.processingFormat, frameCapacity: AVAudioFrameCount(avf.length)) else { throw LeqError.badBuffer }

  try avf.read(into: buf )

  var tmsq : Float = 0
  let k : Float = 23047.0 / 32768
  var leqs : [Float] = []
 // rate = int(fs/10) #sample rate per .1 sec
  let rate = AVAudioFrameCount(avf.fileFormat.sampleRate / 10)
 
  // there are two channels?    buf.format.channelCount    and      buf.format.isInterleaved
  // this is channel 0
  let data = buf.floatChannelData![0]
  
  // while x <= len(data)/rate: #x increases every 0.1 sec which is 4410 samples. Loop stops when time is over.
  // The PCM Buffer has a bunch of frames each of which is a tenth of a second
  var msq : Float = 0
  
  for x in 0..<buf.frameLength {
  // for i in range ((x-1)*rate,rate*x): #recalculate rms every 0.1 sec
      // msq = msq + (data[i]/k)**2 #add the square of the current sample to the sum of the square of the samples within this 0.1 seconds
    // print( data[Int(x)]*32768, pow((data[Int(x)])/k, 2) )
     msq += pow((data[Int(x)])/k, 2)

    // x = x+1
    // tmsq += msq
    
    if (x % rate) == rate-1 {
      tmsq += msq
      if msq != 0 {
        leqs.append( 10*log10((msq/Float(rate))/pow(0.00002,2)) ) // # compute leq over 0.1 sec
      }
      msq = 0
    }

  }
  
  // compute Lmax
  let Lmax = leqs.reduce(-Float.greatestFiniteMagnitude) { max($0, $1) }
  print ("Lmax: ",Lmax)

  print(tmsq)
 // compute total LEQ
  // tleq = 10*np.log10((tmsq/len(data))/(0.00002**2))
  let tleq = 10 * log10( (tmsq / Float(avf.length)) / pow( 0.00002, 2))
   // print ("LEQ: ",tleq)
   return tleq
}

// ======================================================================

// from the Python LeqCalibrationMaster

public func LeqCalibration(_ u : URL) throws -> Float {
// fs, data = wavfile.read('AA_cal_wave')
  
  // guard let u = URL(string: file) else { throw LeqError.badURL(file) }
  let avf = try AVAudioFile.init(forReading: u)

  guard let buf = AVAudioPCMBuffer.init(pcmFormat: avf.processingFormat, frameCapacity: AVAudioFrameCount(avf.length)) else { throw LeqError.badBuffer }

  // fs, data = wavfile.read('AA_cal_wave.wav')
  try avf.read(into: buf )

  // actual = 94 # known leq of sound for calibration
  let actual : Float = 94
 
  var leqs : [Float] = []

  // rate = int(fs/10) #sample rate per .1 sec
  let rate = AVAudioFrameCount(avf.fileFormat.sampleRate / 10)

  // minrun = [1.0]
  var minrun : [Float] = [1.0]
  
  // maxrun = [50000.0]
  var maxrun : [Float] = [50000.0]
 
  // give = 0.1 # +/- amount of leq we are looking for
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
     print (k, tleq)
  }


 print (tleq)
 print (k)
 return k
  
}
