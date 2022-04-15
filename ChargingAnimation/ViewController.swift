//
//  ViewController.swift
//  ChargingAnimation
//
//  Created by Serg on 13.04.22.
//

import UIKit

class ViewController: UIViewController {
    var blobView: BlobView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let fr = CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height - 100)
        blobView = BlobView(frame: fr)
        view.addSubview(blobView)
    }

    @IBAction func go(_ sender: Any) {
        blobView.startAnimating()
    }
    
    
}

