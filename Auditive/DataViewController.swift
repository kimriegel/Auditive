//
//  DataViewController.swift
//  Auditive
//
//  Created by Robert M. Lefkowitz on 4/13/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

import UIKit
import AVFoundation

class DataViewController: UIViewController {

  var microphone : Microphone = Microphone()
  var recordingList : [URL] = []

  @IBOutlet weak var dataLabel: UILabel!
  var dataObject: String = ""
  var audioPlayer : AVAudioPlayer?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.dataLabel!.text = dataObject
  }

  @IBAction func startRecordingSample(_ sender: UIButton) {
    microphone.checkPermission()
    print("recording");
    microphone.startStreaming()

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
        print("delete", contextAction)
      completionHandler(false)
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

}
