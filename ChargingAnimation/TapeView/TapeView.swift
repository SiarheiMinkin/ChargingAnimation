//
//  TapeView.swift
//  ChargingAnimation
//
//  Created by Serg on 13.04.22.
//

import UIKit

class TapeView: UIView {

    enum Constants {
        static let linesCount = 15 // number of circles
        static let pointsCount = 10
        static let gradientColor1 = UIColor(red: 0.5294, green: 0.1961, blue: 0.8667, alpha: 1).cgColor
        static let gradientColor2 = UIColor(red: 0.4235, green: 0.3529, blue: 0.9333, alpha: 1).cgColor
        static let gradientColor3 = UIColor(red: 0.4784, green: 0.2706, blue: 0.898, alpha: 1).cgColor
        static let gradientColor4 = UIColor(red: 0.2136, green: 0.1565, blue: 0.6063, alpha: 1).cgColor
    }
    
    enum State {
        case waiting
        case charging
        case initial
    }
    
    var currentState = State.initial
    var tapeLayers = [TapeLayer]()
    var path: UIBezierPath!
    var delta:CGFloat = 0
    
    lazy var shortestSide: CGFloat = min(self.bounds.size.width, self.bounds.size.height)
    lazy var radiusBase: CGFloat = CGFloat(roundf(Float(shortestSide) / 2))
    lazy var tapeWidth = radiusBase / 3
    var circleLayer: CAShapeLayer!
    var textLayer: CATextLayer!
    var tapeContainerLayer: CALayer!
    var waveContainerLayer: CALayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
        configureLayers()


        
//        // add central circle
//        let circlePath = UIBezierPath(arcCenter:  CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: radiusBase - CGFloat(tapeWidth / 2), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
//        circleLayer.path = circlePath.cgPath
//
//        // Change the fill color
//        circleLayer.fillColor = UIColor.black.cgColor
//        circleLayer.backgroundColor = UIColor.black.cgColor
//        circleLayer.strokeColor = Constants.gradientColor4
//        circleLayer.lineWidth = 1.0
//        circleLayer.shadowOffset = CGSize(width: 0, height: 0)
//        circleLayer.shadowRadius = 10
//        circleLayer.shadowColor = Constants.gradientColor3
//        circleLayer.shadowOpacity = 0.7
//        layer.addSublayer(circleLayer)
//
//        let textLayer = CATextLayer()
//        let textRect = "Charging".boundingRect(with: circleLayer.bounds.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 20)], context: nil)
//        textLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: textRect.height)
//        textLayer.position = CGPoint(x: layer.frame.width / 2, y: layer.frame.height / 2)
//        textLayer.string = "Charging"
//        textLayer.foregroundColor = UIColor.white.cgColor
//        textLayer.alignmentMode = .center
//        textLayer.fontSize = 20
//
//        circleLayer.addSublayer(textLayer)
        
        addNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotifications()
    }
    
    func addNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    @objc func appMovedToBackground() {
//        tapeLayers.forEach({ layer in
//            layer.removeAllAnimations()
//        })
        layer.removeAllAnimations()
        tapeContainerLayer.isHidden = true
    }
    
    @objc func appMovedToForeground() {
        goToState(state: currentState)
    }
    
    func removeNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    func configureLayers() {
        tapeContainerLayer = CALayer()
        tapeContainerLayer.frame = layer.bounds
        // adding animated circles
        path = buildPath(points: Constants.pointsCount)
        for _ in 0...(Constants.linesCount - 1) {
            let tapeLayer = TapeLayer()
            tapeLayer.didFinishAnimation = { [weak self] (layer, flag) in
                self?.didFinishTapeAnimation(layer: layer, flag: flag)
            }
            tapeLayer.frame = bounds
            tapeLayer.path = path.cgPath
            
            tapeLayers.append(tapeLayer)
            tapeLayer.fillColor = UIColor.clear.cgColor
            tapeLayer.shadowOffset = CGSize(width: 0, height: 0)
            tapeLayer.shadowRadius = 1
            tapeLayer.shadowColor = Constants.gradientColor3
            tapeLayer.shadowOpacity = 1
            
            let gradient = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = [Constants.gradientColor1,
                               Constants.gradientColor2,
                               Constants.gradientColor3,
                               Constants.gradientColor4]
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            gradient.mask = tapeLayer

            tapeContainerLayer.addSublayer(gradient)
        }
        layer.addSublayer(tapeContainerLayer)
        tapeContainerLayer.isHidden = true
        
        waveContainerLayer = CALayer()
        waveContainerLayer.frame = layer.bounds
        layer.addSublayer(waveContainerLayer)
        
        // add central circle
        circleLayer = CAShapeLayer()
        circleLayer.frame = layer.bounds
        let circlePath = UIBezierPath(arcCenter:  CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: radiusBase - CGFloat(tapeWidth / 2), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circleLayer.path = circlePath.cgPath
            
        // Change the fill color
        circleLayer.fillColor = UIColor.black.cgColor
        circleLayer.backgroundColor = UIColor.clear.cgColor
        circleLayer.strokeColor = Constants.gradientColor4
        circleLayer.lineWidth = 1.0
        circleLayer.shadowPath = circlePath.cgPath
        circleLayer.shadowOffset = CGSize(width: 0, height: 0)
        circleLayer.shadowRadius = 10
        circleLayer.shadowColor = Constants.gradientColor3
        circleLayer.shadowOpacity = 0.7
      //  layer.addSublayer(circleLayer)
        
        textLayer = CATextLayer()
        let textRect = "Waiting".boundingRect(with: circleLayer.bounds.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 20)], context: nil)
        textLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: textRect.height)
        textLayer.position = CGPoint(x: layer.frame.width / 2, y: layer.frame.height / 2)
        textLayer.string = "Charging"
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .center
        textLayer.fontSize = 20
        circleLayer.addSublayer(textLayer)
        layer.addSublayer(circleLayer)
    }
    
    func goToState(state: State) {
        layer.removeAllAnimations()
       // layer.sublayers?.removeAll()
        
        if currentState != state {

            
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.delegate = self
            animation.fromValue = layer.value(forKeyPath: "transform.scale")
            animation.toValue = 0
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.isRemovedOnCompletion = false
            layer.add(animation, forKey: "transform.scale.min")
            layer.animateOpacity(timeOffset: 0, duration: 0.5, fromValue: 1, toValue: 0)
            layer.opacity = 0
            circleLayer.opacity = 0
        }

        
        switch state {
        case .waiting:

            if currentState == .initial {
                circleLayer.isHidden = false
            }
        case .charging:
            if currentState == .waiting {
                circleLayer.isHidden = false
            } else {
                showTapeAnimating(fromInitialState: false)
            }
//            tapeLayers.forEach({ layer in
//                layer.removeAllAnimations()
//            })
//            layer.removeAllAnimations()
//            showTapeAnimating()
        //    showWaveAnimation()
            
            
        case .initial:
            ()
        }
        currentState = state
    }
    
    func didFinishTapeAnimation(layer: TapeLayer, flag: Bool) {
        guard flag else {return}
        print("didFinishAnimation")
        if layer == tapeLayers.first {
            path = buildPath(points: Constants.pointsCount)
        }
        
        layer.animateNewPath(newPath: path, timeOffset: 0, duration: 2)

        
    }
    
    
    func showWaveAnimation() {
        let circlePath = UIBezierPath(arcCenter:  CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: 0, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        var animationLayers = [TapeLayer]()
        let waveCount = 5
        var duration: CFTimeInterval = 0.5
        var timeInterval: CFTimeInterval = duration
        
        for _ in 0...waveCount {
            let tapeLayer = TapeLayer()
            animationLayers.append(tapeLayer)
            
            tapeLayer.fillColor = UIColor.clear.cgColor
            tapeLayer.strokeColor = Constants.gradientColor3
            
            tapeLayer.path = circlePath.cgPath
            tapeLayer.didFinishAnimation = { (layer, flag) in
                layer.removeFromSuperlayer()
            }
            waveContainerLayer.addSublayer(tapeLayer)
        }
       let step = duration / Double(waveCount)
        animationLayers.forEach { [weak self] layer in
            timeInterval = timeInterval - step
            layer.animateNewPath(newPath: path, timeOffset: timeInterval, duration: duration)
            //layer.animateOpacity(timeOffset: timeInterval, duration: 0.5)
        }
        
    }
    
    func showTapeAnimating(fromInitialState: Bool) {
        var duration: CFTimeInterval = 2
        
//        if fromInitialState {
//            path = buildPath(points: Constants.pointsCount)
//            for index in 0..<tapeLayers.count {
//                let layer = tapeLayers[index]
//                let linesCount = 7
//                if index > tapeLayers.count - linesCount {
//                    let scale: CGFloat = 0.7//CGFloat(((tapeLayers.count - index) / 2) / linesCount)
//                    let initialPath = path!
//                    initialPath.scaleAroundCenter(factor: scale)
//                    layer.path = initialPath.cgPath
//                } else {
//                    layer.path = path.cgPath
//                }
//            }
//            duration = 0.7
//        }
        var timeInterval: CFTimeInterval = duration
        tapeContainerLayer.isHidden = false
        path = buildPath(points: Constants.pointsCount)
        tapeLayers.forEach { [weak self] layer in
            timeInterval = timeInterval - timeInterval / Double(Constants.linesCount) * 2
            layer.animateNewPath(newPath: path, timeOffset: timeInterval, duration: duration)
        }
    }
    
    func buildPath(points: Int) -> UIBezierPath {
        //build a closed path that is a distorted polygon.
        var path = UIBezierPath()
        
        delta += (Double.pi * 1.5 / Double(points))
        for step in 0...(points - 1) {
            
            //Step around a circle
            let angle = CGFloat(Double.pi * 2) / CGFloat(points) * CGFloat(step) + delta
            let radius = radiusBase - CGFloat.random(in: 0...tapeWidth)
            let x = CGFloat(roundf(Float(CGFloat(cosf(Float(angle))) * radius + CGFloat(frame.size.width / 2))))
            let y = CGFloat(roundf(Float(CGFloat(sinf(Float(angle))) * radius + CGFloat(frame.size.height / 2))))
            
            let aPoint = CGPoint(x: x, y: y)
            if (step == 0) {
                path.move(to: aPoint)
            }
            else
            {
                path.addLine(to: aPoint)
            }
        }
        
        //Now convert our polygon path to a curved shape
        path.close()
        path = path.smoothedPath(granularity: 10)!
        return path
    }
}

extension TapeView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == layer.animation(forKey: "transform.scale.min") {
            tapeContainerLayer.isHidden = true
            
            if currentState == .waiting {
                textLayer.string = "Waiting"
                layer.removeAllAnimations()
            } else {
                tapeContainerLayer.isHidden = false
                showTapeAnimating(fromInitialState: false)
                showWaveAnimation()
                textLayer.string = "Charging"
                layer.removeAllAnimations()
            }
            
            circleLayer.opacity = 1
            layer.opacity = 1
            layer.animateOpacity(timeOffset: 0, duration: 0.2, fromValue: 0, toValue: 1)
            circleLayer.animateOpacity(timeOffset: 0, duration: 0.5, fromValue: 0, toValue: 1)

            circleLayer.isHidden = false
            
        }
//        if currentState == .waiting {
//            goToState(state: .charging)
//        }
    }
}

extension UIBezierPath {

    func scaleAroundCenter(factor: CGFloat) {
        let beforeCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

        // SCALE path by factor
        let scaleTransform = CGAffineTransform(scaleX: factor, y: factor)
        self.apply(scaleTransform)

        let afterCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let diff = CGPoint( x: beforeCenter.x - afterCenter.x, y: beforeCenter.y - afterCenter.y)

        let translateTransform = CGAffineTransform(translationX: diff.x, y: diff.y)
        self.apply(translateTransform)
    }

}
