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
        let fr = CGRect(x: 50, y: 300, width: 300, height: 300)
        blobView = BlobView(frame: fr)
        view.addSubview(blobView)
    }

    @IBAction func go(_ sender: Any) {
        blobView.startAnimating()
    }
    
    
}

