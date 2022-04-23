//
//  TapeLayer.swift
//  ChargingAnimation
//
//  Created by Serg on 13.04.22.
//

import UIKit

class TapeLayer: CAShapeLayer, CAAnimationDelegate {
    var didFinishAnimation: ((_ layer: TapeLayer, _ isFifnished: Bool)->())?
    override init() {
        super.init()
        strokeColor = UIColor.black.cgColor
        lineWidth = 1
        self.fillColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateNewPath(newPath: UIBezierPath, timeOffset: CFTimeInterval, duration: CFTimeInterval = 2) {
        let oldPath = self.path
        self.path = newPath.cgPath
        
        let animate = oldPath != nil
        if (animate)
        {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = oldPath
            pathAnimation.toValue = newPath.cgPath
            pathAnimation.duration = duration
            pathAnimation.timeOffset = timeOffset
            pathAnimation.repeatDuration = pathAnimation.duration - pathAnimation.timeOffset
            pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            pathAnimation.repeatCount = 0
            pathAnimation.delegate = self
            self.add(pathAnimation, forKey: "pathAnimation")
        }
    }


    //CAAnimation delegate methods
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        didFinishAnimation?(self, flag)
    }
}
