//
//  TapeView.swift
//  ChargingAnimation
//
//  Created by Serg on 13.04.22.
//

import UIKit

class TapeView: UIView {

    enum Constants {
        static let linesCount = 14 // number of circles
        static let pointsCount = 9 // random point in circle
        static let gradientColor1 = UIColor(red: 0.5294, green: 0.1961, blue: 0.8667, alpha: 1).cgColor
        static let gradientColor2 = UIColor(red: 0.4235, green: 0.3529, blue: 0.9333, alpha: 1).cgColor
        static let gradientColor3 = UIColor(red: 0.4784, green: 0.2706, blue: 0.898, alpha: 1).cgColor
        static let gradientColor4 = UIColor(red: 0.2136, green: 0.1565, blue: 0.6063, alpha: 1).cgColor
        static let font = UIFont.boldSystemFont(ofSize: 40)
    }
    
    enum State: String {
        case waiting = "Waiting"
        case charging = "Charging"
    }
    
    // MARK: - Private properties
    private var currentState = State.waiting
    private var tapeLayers = [TapeLayer]()
    private var path: UIBezierPath!
    private var delta:CGFloat = 0
    
    private lazy var shortestSide: CGFloat = min(self.bounds.size.width, self.bounds.size.height)
    private lazy var radiusBase: CGFloat = CGFloat(roundf(Float(shortestSide) / 2))
    private lazy var tapeWidth = radiusBase / 2
    private var circleLayer: CAShapeLayer!
    private var textLayer: CATextLayer!
    private var tapeContainerLayer: CALayer!
    private var waveContainerLayer: CALayer!
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        configureLayers()
        addNotifications()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
        configureLayers()
        addNotifications()
    }
    
    deinit {
        removeNotifications()
    }
    
    // MARK: - Public methods
    public func goToState(state: State) {
        layer.removeAllAnimations()
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
            circleLayer.isHidden = false
            tapeContainerLayer.isHidden = true
        case .charging:
            if currentState == .waiting {
            circleLayer.isHidden = false
            tapeContainerLayer.isHidden = true
            } else {
                showTapeAnimation()
            }
        }
        currentState = state
    }
    
    // MARK: - Notifications
    private func addNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func removeNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    @objc private func appMovedToBackground() {
        layer.removeAllAnimations()
        tapeContainerLayer.isHidden = true
    }
    
    @objc private func appMovedToForeground() {
        goToState(state: currentState)
    }
    
    // MARK: - Layout
    private func configureLayers() {
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
        let circlePath = UIBezierPath(arcCenter:  CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: radiusBase - CGFloat(tapeWidth / 4), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circleLayer.path = circlePath.cgPath
            
        circleLayer.fillColor = UIColor.black.cgColor
        circleLayer.backgroundColor = UIColor.clear.cgColor
        circleLayer.strokeColor = Constants.gradientColor4
        circleLayer.lineWidth = 1.0
        circleLayer.shadowPath = circlePath.cgPath
        circleLayer.shadowOffset = CGSize(width: 0, height: 0)
        circleLayer.shadowRadius = 10
        circleLayer.shadowColor = Constants.gradientColor3
        circleLayer.shadowOpacity = 0.7
        
        textLayer = CATextLayer()
        let textRect = State.waiting.rawValue.boundingRect(with: circleLayer.bounds.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : Constants.font], context: nil)
        textLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: textRect.height)
        textLayer.position = CGPoint(x: layer.frame.width / 2, y: layer.frame.height / 2)
        textLayer.string = State.waiting.rawValue
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .center
        textLayer.font = Constants.font
        circleLayer.addSublayer(textLayer)
        layer.addSublayer(circleLayer)
    }
    
   private func didFinishTapeAnimation(layer: TapeLayer, flag: Bool) {
        guard flag else {return}
        if layer == tapeLayers.first {
            path = buildPath(points: Constants.pointsCount)
        }
        layer.animateNewPath(newPath: path, timeOffset: 0, duration: 2)
    }
    
   private func showWaveAnimation() {
        let circlePath = UIBezierPath(arcCenter:  CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: 0, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        var animationLayers = [TapeLayer]()
        let waveCount = 5
        let duration: CFTimeInterval = 0.5
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
        animationLayers.forEach { layer in
            timeInterval = timeInterval - step
            layer.animateNewPath(newPath: path, timeOffset: timeInterval, duration: duration)
        }
    }
    
  private func showTapeAnimation() {
        let duration: CFTimeInterval = 2
        var timeInterval: CFTimeInterval = duration
        tapeContainerLayer.isHidden = false
        path = buildPath(points: Constants.pointsCount)
      
        tapeLayers.forEach { layer in
            timeInterval = timeInterval - duration / Double(Constants.linesCount)
            layer.animateNewPath(newPath: path, timeOffset: timeInterval, duration: duration)
        }
    }
    
  private func buildPath(points: Int) -> UIBezierPath {
        //build a closed path that is a distorted polygon.
        var path = UIBezierPath()
        delta += (Double.pi * 1.5 / Double(points))
        for step in 0...(points - 1) {
            
            //Step around a circle
            let angle = CGFloat(Double.pi * 2) / CGFloat(points) * CGFloat(step) + delta
            var width = tapeWidth
            if step % 2 == 0 {
                width = CGFloat(Int.random(in: 0...Int(tapeWidth / 4)))
            } else {
                width = CGFloat(Int.random(in: Int(tapeWidth / 4)...Int(tapeWidth)))
            }
            let radius = radiusBase - CGFloat.random(in: 0...width)
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

// MARK: - CAAnimationDelegate
extension TapeView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == layer.animation(forKey: "transform.scale.min") {
            tapeContainerLayer.isHidden = true
            
            if currentState == .waiting {
                textLayer.string = State.waiting.rawValue
                layer.removeAllAnimations()
            } else {
                tapeContainerLayer.isHidden = false
                showTapeAnimation()
                showWaveAnimation()
                textLayer.string = State.charging.rawValue
                layer.removeAllAnimations()
            }
            
            circleLayer.opacity = 1
            layer.opacity = 1
            layer.animateOpacity(timeOffset: 0, duration: 0.2, fromValue: 0, toValue: 1)
            circleLayer.animateOpacity(timeOffset: 0, duration: 0.5, fromValue: 0, toValue: 1)
            circleLayer.isHidden = false
        }
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

