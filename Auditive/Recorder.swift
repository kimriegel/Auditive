//
//  Recorder.swift
//  Auditive
//
//  Created by Robert M. Lefkowitz on 4/24/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import os

class Microphone: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
  private var permissionGranted = false
  private var audioEngine : AVAudioEngine!
  private var frameCount : Int = 0
  private var counter : Int = 0 // number of captured frames
  private var afile : AVAudioFile!
  private var musicQ : DispatchQueue = DispatchQueue.init(label: "musicGrabber", attributes: [])


  override init() {
    super.init()
    checkPermission()
  }

  func checkPermission() {
    switch AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) {
    case .authorized:
      permissionGranted = true
    case .notDetermined:
      requestPermission()
    case .denied:
      os_log("%s", type: .error, "**** can't use the microphone!!!");
    case .restricted:
      os_log("%s", type: .error, "*** restricted microphone use!!!");
    default:
      permissionGranted = false
    }
  }

  private func requestPermission() {
    // sessionQueue.suspend()
    AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
      self.permissionGranted = granted
      // self.sessionQueue.resume()
    }
  }

  /*
  func selectCaptureDevice() -> AVCaptureDevice? {
    let j = AVCaptureDevice.devices(for: AVMediaType.audio).filter { d in
      d.localizedName.starts(with: "LG")
    }
    return j.first
  }
 */

  func startStreaming(onCompletion : @escaping (URL)->() ) {
    // let _ = self.selectCaptureDevice()

   // let j = self.audioDeviceList()

    audioEngine  = AVAudioEngine()
    let inputNode = audioEngine.inputNode

   // let inputUnit: AudioUnit = inputNode.audioUnit!

//    var inputDeviceID: AudioDeviceID = j[0]
//    AudioUnitSetProperty(inputUnit, kAudioOutputUnitProperty_CurrentDevice,
//                         kAudioUnitScope_Global, 0, &inputDeviceID, UInt32(MemoryLayout<AudioDeviceID>.size))


    let bus = 0
    let z : AVAudioFormat = inputNode.outputFormat(forBus: bus)
    // let h = z.sampleRate
    // let j = z.channelCount
    // let k = z.formatDescription
    // let m = z.commonFormat
    // let n = z.formatDescription

    let bs = Int(z.sampleRate) //  / 10.0) // sampling is at 1 tenth of a second?   Always?
    // buffer size for a second worth of audio?

    // os_log("%s", type:.debug, "sample rate \(h), channel count \(j), format description \(k), common format \(m), format description \(n), buffer size \(bs)")

    frameCount = Int(bs / 60 )
    // this is FFT related stuff

      // nover2 = vDSP_Length(frameCount/2)
      // log2n = vDSP_Length(log2f(Float(frameCount)))
      // bufferSizePOT = Int(1<<log2n)
      // let windowSize = bufferSizePOT

      // inputCount = bufferSizePOT / 2

      // fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))!

      // dftSetup = vDSP_DFT_zrop_CreateSetup(nil, vDSP_Length(bufferSizePOT), .FORWARD)

      // window = [Float](repeating: 0, count: frameCount)
      // tempWindow = [Float](repeating: 0, count: frameCount)
      // vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_DENORM))

      // realp = [Float](repeating: 0, count: inputCount)
      // imagp = [Float](repeating: 0, count: inputCount)
      // split = DSPSplitComplex(realp: &realp, imagp: &imagp)
      // magnitudes = [Float](repeating: 0, count: inputCount)
      // normalizedMagnitudes = [Float](repeating: 0, count: inputCount)
      //
      // outputR = [Float](repeating: 0, count: Int(inputCount))
      // outputI = [Float](repeating: 0, count: Int(inputCount))
      //
      // transferBuffer = [Float](repeating: 0, count: windowSize)

    // tempBuffer = UnsafeMutablePointer<Float>.allocate(capacity: numSamples)

    // inputNode.installTap(onBus: bus, bufferSize: AVAudioFrameCount(bs), format: inputNode.outputFormat(forBus: bus), block: self.captured)

    inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(frameCount), format: inputNode.outputFormat(forBus: bus), block: self.captured)

    audioEngine!.prepare()

    let iff = inputNode.outputFormat(forBus: bus)

    let recordSettings : [String:Any] = [
      // AVFormatIDKey: kAudioFormatAppleLossless,
      AVFormatIDKey: kAudioFormatLinearPCM,
      // AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
      // AVEncoderBitRateKey : 320000,
      AVNumberOfChannelsKey : iff.channelCount,
      // AVChannelLayoutKey : iff.channelLayout as Any,
      AVSampleRateKey : iff.sampleRate
    ]

    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let dateFormatter : DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let time = dateFormatter.string(from: Date())
    let url = path.appendingPathComponent("s-\(time)")

    let clipLength = 3
    do {
      try afile = AVAudioFile.init(forWriting: url, settings: recordSettings)
      try audioEngine!.start()
      DispatchQueue.global().asyncAfter(wallDeadline: DispatchWallTime.now()+DispatchTimeInterval.seconds(clipLength)) {
        self.audioEngine!.stop()
        onCompletion(self.afile.url)
        print(self.afile.url,self.afile.framePosition, self.afile.length)
      }
    } catch let e {
      os_log("%s", type:.debug, "audioEngine start: \(e.localizedDescription)")
    }

  }





  func captured(buffer: AVAudioPCMBuffer, timex: AVAudioTime) {
    // os_log("%s", type:.debug, "\(timex.sampleTime,timex.sampleRate)")

    counter += 1
    // print("audio capture:", counter,  buffer.frameCapacity, buffer.frameLength)

 /*   guard let fcd = buffer.floatChannelData else {
      os_log("%s", type:.error, "didn't have floatChannelData")
      return
    }
*/


    musicQ.async {
      do {
        try self.afile.write(from: buffer)
      } catch {
        print("writing file", error)
      }
    }

    /*
    let siz = MemoryLayout<Float32>.stride * Int(buffer.frameLength)
    fcd[0].withMemoryRebound(to: UInt8.self, capacity: siz) {
      ptr in
      inBuffer.append(ptr, count: siz)
    }*/

    // let jjj = Array(UnsafeBufferPointer<Float>(start: fcd[0] , count: Int(buffer.frameLength)) )
    // print(jjj)

    /*
    musicQ.async(flags: .barrier) {
      let bufsiz = Int(timex.sampleRate) * MemoryLayout<Float32>.stride / 60
      while(self.inBuffer.endIndex - self.inBuffer.startIndex > bufsiz) {

        // sampleRate is the number of tenths of a second
        // a tenth of a second would be roughly 4410 numbers for a 44100 sampling rate
        // a 60th of a second would be one sixth of the sample

        // print( time.hostTime, time.sampleRate, time.sampleTime, time.isSampleTimeValid, time.isHostTimeValid)


        // print("buffer: \(buffer.frameLength), \(buffer.frameCapacity), \(buffer.stride)" )


        // is this nil ?
        // let nb2 = Data(bytes: fcd[1] + i * stride, count: stride * MemoryLayout<Float32>.stride )

        // print("buffer appended \(nb.count)")

        let nbx = self.inBuffer.subdata(in: self.inBuffer.startIndex..<self.inBuffer.startIndex + bufsiz)
        self.inBuffer.removeFirst(bufsiz)


        nbx.withUnsafeBytes { ( ptr : UnsafeRawBufferPointer ) -> Void in

          let bs = bufsiz / MemoryLayout<Float32>.stride
          let pp = ptr.baseAddress! // .advanced(by: self.inBuffer.startIndex)
          let nbx = Data(bytes: pp, count: bufsiz)
          // pp.bindMemory(to: Float.self, capacity: bs)
          // let njj = (0..<bs).map { nbx[$0] }
          let nb3 = self.doFFT(pp.bindMemory(to: Float.self, capacity: bs), bs)
          //           let nb3 = pp.withMemoryRebound(to: Float.self, capacity: bs) { (f : UnsafePointer<Float>) -> Data in
          // return Data(count: 256)
          //               return self.doFFT( f, bs )
          // let nb3 = Data(bytes : &self.normalizedMagnitudes, count: self.normalizedMagnitudes.count * MemoryLayout<Float>.size )

          // return Data(bytes : &self.outputR, count: self.outputR.count * MemoryLayout<Float>.stride)

          // }

          self.buffer.append( (nbx, nb3) )
        }
        // print( Data.init(bytesNoCopy: self.output, count: 512, deallocator: Data.Deallocator.none).base64EncodedString() )
      }
      self.inBuffer = self.inBuffer.subdata(in: self.inBuffer.startIndex..<self.inBuffer.endIndex)
    }
     */
  }

/*
  func selectCaptureDevice() -> AVCaptureDevice? {
    let j = AVCaptureDevice.devices(for: AVMediaType.audio).filter { d in
      d.localizedName.starts(with: "LG")
    }
    return j.first
  }
*/

/*
  func audioDeviceList() -> [AudioDeviceID] {
    var mDevices : [AudioDeviceID] = []

    var propsize : UInt32 = 0

    var theAddress : AudioObjectPropertyAddress = AudioObjectPropertyAddress.init(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)

    // = [ AudioObjectID(kAudioHardwarePropertyDevices),
    // kAudioObjectPropertyScopeGlobal,
    // kAudioObjectPropertyElementMaster ]

    let _ = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &theAddress, 0, nil, &propsize)
    // print("AudioObjectGetPropertyDataSize", err)
    let nDevices : Int = Int(propsize) / MemoryLayout<AudioDeviceID>.stride

    var devids : [AudioDeviceID] = Array(repeating: 0, count: nDevices)

    let _ = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &theAddress, 0, nil, &propsize, &devids)
    // print("AudioObjectGetPropertyData", err2)

    for j in devids {
      mDevices.append(j)
      // print(audioDeviceGetName(j) as Any)
      // print("channels", audioDeviceCountChannels(j))
    }
    return mDevices
  }
*/
/*
  func audioDeviceCountChannels(_ mID : AudioDeviceID) -> Int {
    let theScope : AudioObjectPropertyScope = /* mIsInput ? */ kAudioDevicePropertyScopeInput // : kAudioDevicePropertyScopeOutput;

    var theAddress = AudioObjectPropertyAddress.init(mSelector: kAudioDevicePropertyStreamConfiguration, mScope: theScope, mElement: 0)

    var propSize : UInt32 = 0

    var result = 0

    let err = AudioObjectGetPropertyDataSize(mID, &theAddress, 0, nil, &propSize);
    if (err != 0) { return 0 }

    var buflist : [AudioBufferList] = Array(repeating: AudioBufferList(), count: Int(propSize) / MemoryLayout<AudioBufferList>.size)
    let err2 = AudioObjectGetPropertyData(mID, &theAddress, 0, nil, &propSize, &buflist)
    if (err2 == 0) {
      for buf in buflist {
        result += Int(buf.mBuffers.mNumberChannels)
      }
    }
    return result
  }
*/

  /*
  func audioDeviceGetName(_ mID : AudioDeviceID) -> String? {
    let theScope : AudioObjectPropertyScope = /* mIsInput ?  */ kAudioDevicePropertyScopeInput // : kAudioDevicePropertyScopeOutput;
    var theAddress = AudioObjectPropertyAddress.init(mSelector: kAudioDevicePropertyDeviceName, mScope: theScope, mElement: 0)
    var maxlen : UInt32 = 1024
    var buf : Data = Data(count: Int(maxlen) )
    let err = buf.withUnsafeMutableBytes { AudioObjectGetPropertyData(mID, &theAddress, 0, nil,  &maxlen, $0.baseAddress!) }
    os_log("%s", type: .debug, "AudioObjectGetPropertyData \(err)")
    return String.init(data:   buf.subdata(in: 0..<Int(maxlen-1))  , encoding: .utf8)
  }*/

  /*
  func audioDeviceSetBufferSize(_ mID : AudioDeviceID, _ z : Int) {
    var size = z
    var propsize : UInt32 = UInt32( MemoryLayout<UInt32>.size )
    let theScope : AudioObjectPropertyScope = /* mIsInput ?  */ kAudioDevicePropertyScopeInput // : kAudioDevicePropertyScopeOutput;
    var theAddress = AudioObjectPropertyAddress.init(mSelector: kAudioDevicePropertyBufferSize, mScope: theScope, mElement: 0)
    let err = AudioObjectSetPropertyData(mID, &theAddress, 0, nil, propsize, &size)
    os_log("%s", type: .debug, "AudioObjectSetPropertyData \(err)" )
    var mBufferSizeFrames : UInt32 = 0
    let err2 = AudioObjectGetPropertyData(mID, &theAddress, 0, nil, &propsize, &mBufferSizeFrames)
    os_log("%s", type: .debug, "AudioObjectGetPropertyData \(err2)")
    if (size != mBufferSizeFrames) {
      os_log("%s", type:.error, "size set is not equal to size got (\(size) <=> \(mBufferSizeFrames))")
    }
  }
*/

  func listOfRecordings() -> [URL] {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    do {
      let paths = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants])
      return paths.sorted {  $0.lastPathComponent > $1.lastPathComponent } 
    } catch {
      print("getting list of paths", error)
    }
    return []
  }

}
