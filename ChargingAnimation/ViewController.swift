//
//  ViewController.swift
//  ChargingAnimation
//
//  Created by Serg on 13.04.22.
//

import UIKit

class ViewController: UIViewController {
    var tapeView: TapeView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let fr = CGRect(x: 50, y: 300, width: 300, height: 300)
        tapeView = TapeView(frame: fr)
        view.addSubview(tapeView)
    }

    @IBAction func go(_ sender: Any) {
        tapeView.startAnimating()
    }
    
    
}

