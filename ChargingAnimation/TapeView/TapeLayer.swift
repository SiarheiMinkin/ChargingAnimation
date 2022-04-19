//
//  TapeLayer.swift
//  ChargingAnimation
//
//  Created by Serg on 13.04.22.
//

import UIKit

class TapeLayer: CAShapeLayer, CAAnimationDelegate {
    var didFinishAnimation: ((_ layer: TapeLayer)->())?
    override init() {
        super.init()
        strokeColor = UIColor.black.cgColor
        lineWidth = 1
        self.fillColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateNewPath(newPath: UIBezierPath, layer: CAShapeLayer, timeOffset: CFTimeInterval) {
        let oldPath = layer.path
        layer.path = newPath.cgPath
        
        let animate = oldPath != nil
        if (animate)
        {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = oldPath
            pathAnimation.toValue = newPath.cgPath
            pathAnimation.duration = 2
            pathAnimation.timeOffset = timeOffset
            pathAnimation.repeatDuration = pathAnimation.duration - pathAnimation.timeOffset
            pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            if (layer == self) {
                pathAnimation.delegate = self
            }
            layer.add(pathAnimation, forKey: "pathAnimation")
        }
    }

    //CAAnimation delegate methods
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        didFinishAnimation?(self)
    }
}
