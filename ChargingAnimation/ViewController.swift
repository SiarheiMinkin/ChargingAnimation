//
//  ViewController.swift
//  ChargingAnimation
//
//  Created by Serg on 13.04.22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tapeView: TapeView!
    override func viewDidLoad() {
        super.viewDidLoad()
     //   let fr = CGRect(x: 50, y: 300, width: 300, height: 300)
     //   view.addSubview(tapeView)
       // tapeView.showTapeAnimating()
      //  tapeView.goToState(state: .waiting)
    }

    @IBAction func charging(_ sender: Any) {
        tapeView.goToState(state: .charging)
    }
    
    @IBAction func waiting(_ sender: Any) {
        tapeView.goToState(state: .waiting)
    }
}

