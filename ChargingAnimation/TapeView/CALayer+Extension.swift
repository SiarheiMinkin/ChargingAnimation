//
//  CALayer+Extension.swift
//  ChargingAnimation
//
//  Created by Serg on 23.04.22.
//

import Foundation
import QuartzCore

extension CALayer {
    func animateOpacity(timeOffset: CFTimeInterval, duration: CFTimeInterval = 2, fromValue: Any?, toValue: Any?) {
            let pathAnimation = CABasicAnimation(keyPath: "opacity")
            pathAnimation.fromValue = fromValue
            pathAnimation.toValue = toValue
            pathAnimation.duration = duration
            pathAnimation.timeOffset = timeOffset
            pathAnimation.repeatDuration = pathAnimation.duration - pathAnimation.timeOffset
            pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            pathAnimation.repeatCount = 0
            //pathAnimation.delegate = self
            self.add(pathAnimation, forKey: "opacityAnimation")
        }
}
