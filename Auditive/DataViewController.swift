//
//  DataViewController.swift
//  Auditive
//
//  Created by Robert M. Lefkowitz on 4/13/19.
//  Copyright © 2019 Semasiology. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {

  @IBOutlet weak var dataLabel: UILabel!
  var dataObject: String = ""


  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.dataLabel!.text = dataObject
  }

  @IBAction func startRecordingSample(_ sender: UIButton) {
    print("recording");
  }

}

