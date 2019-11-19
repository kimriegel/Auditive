//
//  DataViewController.swift
//  Auditive
//
//  Created by Robert M. Lefkowitz on 4/13/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

//here is a fancy new comment that will change your life
//Hello, my name is mahmud.
//Watch me overcomment this like crazy
import UIKit
import AVFoundation
import os
import AudioKitUI
import AudioKit

class DataViewController: UIViewController {

    
    
    
    //Hi nice to meet you
    //I see you're reading my code
    //Well, below is all the private variables that i added.
    //I am gonna fix this and clean it up because most of these private vars i Do not need at all.
    
    
    
       @IBOutlet private var frequencyLabel: UILabel!
       @IBOutlet private var amplitudeLabel: UILabel!
       @IBOutlet private var noteNameWithSharpsLabel: UILabel!
       @IBOutlet private var noteNameWithFlatsLabel: UILabel!
       @IBOutlet private var audioInputPlot: EZAudioPlot!

       var mic: AKMicrophone!
       var tracker: AKFrequencyTracker!
       var silence: AKBooster!

       let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
       let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
       let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    
    
    
    
    
    
    
    
    
    
    @IBOutlet var plot: AKNodeOutputPlot?

    var oscillator1 = AKOscillator()
    var oscillator2 = AKOscillator()
    var mixer = AKMixer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mixer = AKMixer(oscillator1, oscillator2)

        // Cut the volume in half since we have two oscillators
        mixer.volume = 0.5
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    @IBAction func toggleSound(_ sender: UIButton) {
        if oscillator1.isPlaying {
            oscillator1.stop()
            oscillator2.stop()
            sender.setTitle("Play Sine Waves", for: .normal)
        } else {
            oscillator1.frequency = random(in: 220 ... 880)
            oscillator1.start()
            oscillator2.frequency = random(in: 220 ... 880)
            oscillator2.start()
            sender.setTitle("Stop \(Int(oscillator1.frequency))Hz & \(Int(oscillator2.frequency))Hz", for: .normal)
        }
    }

    
    
    
    
    
    
    
    
    
    
    
  var microphone : Microphone = Microphone()
  var recordingList : [URL] = []

  @IBOutlet weak var dataLabel: UILabel!
  @IBOutlet var tableView : UITableView!

  var dataObject: String = ""
  var audioPlayer : AVAudioPlayer?



  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    DispatchQueue.main.async { self.dataLabel!.text = self.dataObject }
  }

  @IBAction func startRecordingSample(_ sender: UIButton) {
    microphone.checkPermission()
    print("recording");
    microphone.startStreaming { url in
      self.recordingList.insert(url, at: 0)
      DispatchQueue.main.async { self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top) }
      // DispatchQueue.main.async { self.tableView.reloadData(); }
    }
    print("done")
  }

}

extension DataViewController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    recordingList = microphone.listOfRecordings();
    return recordingList.count;
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "recordingName", for: indexPath)
    cell.textLabel?.text = recordingList[indexPath.row].lastPathComponent
    return cell
  }

}

extension DataViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
    let flagAction = self.contextualToggleFlagAction(forRowAtIndexPath: indexPath)
    let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, flagAction])
    return swipeConfig
  }

  func contextualDeleteAction(forRowAtIndexPath: IndexPath) -> UIContextualAction {
    let action = UIContextualAction(style: .normal, title: "Delete") {
      (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
      let t = forRowAtIndexPath
      let u = self.recordingList[t.row]
      print("deleting", u)
      do {
        try FileManager.default.removeItem(at: u)
        self.tableView.deleteRows(at: [t], with: .right)
        completionHandler(true)
      } catch {
        os_log("deleting: %s", type: .error, error.localizedDescription)
        completionHandler(false)
      }
    }
    action.backgroundColor = UIColor.red
    return action
  }

  func contextualToggleFlagAction(forRowAtIndexPath: IndexPath) -> UIContextualAction {
    let action = UIContextualAction(style: .normal, title: "Flag") {
      (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
      print("flag", contextAction)
      completionHandler(false)
    }
    action.backgroundColor = UIColor.gray
    return action
  }

  // =========================

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    do {
      print(recordingList[indexPath.row] )
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)

      audioPlayer = try AVAudioPlayer(contentsOf: recordingList[indexPath.row], fileTypeHint: AVFileType.aiff.rawValue)
      DispatchQueue.main.async {
      self.audioPlayer?.play()
      }
    } catch let error {
      print("Can't play the audio file failed with an error \(error.localizedDescription)")
    }


  }

    
    
    
    
//=======================================Commentedout because of mic error. will fix soon========================
//=======================================Commentedout because of mic error. will fix soon========================
//=======================================Commentedout because of mic error. will fix soon========================
    //=======================================Commentedout because of mic error. will fix soon========================
    //=======================================Commentedout because of mic error. will fix soon========================
    //=======================================Commentedout because of mic error. will fix soon========================
    //=======================================Commentedout because of mic error. will fix soon========================
    /*
   

    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.translatesAutoresizingMaskIntoConstraints = false
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)

        // Pin the AKNodeOutputPlot to the audioInputPlot
        var constraints = [plot.leadingAnchor.constraint(equalTo: audioInputPlot.leadingAnchor)]
        constraints.append(plot.trailingAnchor.constraint(equalTo: audioInputPlot.trailingAnchor))
        constraints.append(plot.topAnchor.constraint(equalTo: audioInputPlot.topAnchor))
        constraints.append(plot.bottomAnchor.constraint(equalTo: audioInputPlot.bottomAnchor))
        constraints.forEach { $0.isActive = true }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        setupPlot()

    } */
/*
    @objc func updateUI() {
        if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)

            var frequency = Float(tracker.frequency)
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }

            var minDistance: Float = 10_000.0
            var index = 0

            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
             
   */
    
    
    
    
    
    
}


