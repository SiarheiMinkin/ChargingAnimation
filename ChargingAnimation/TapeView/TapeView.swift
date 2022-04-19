//
//  TapeView.swift
//  ChargingAnimation
//
//  Created by Serg on 13.04.22.
//

import UIKit

class TapeView: UIView {

    enum Constants {
        static let linesCount = 20 // number of circles
        static let pointsCount = 12
        static let tapeWidth: CGFloat = 40
        static let gradientColor1 = UIColor(red: 0.5294, green: 0.1961, blue: 0.8667, alpha: 1).cgColor
        static let gradientColor2 = UIColor(red: 0.4235, green: 0.3529, blue: 0.9333, alpha: 1).cgColor
        static let gradientColor3 = UIColor(red: 0.4784, green: 0.2706, blue: 0.898, alpha: 1).cgColor
        static let gradientColor4 = UIColor(red: 0.2136, green: 0.1565, blue: 0.6063, alpha: 1).cgColor
    }

    var layers = [TapeLayer]()
    var path: UIBezierPath!
    var delta:CGFloat = 0
    lazy var shortestSide: CGFloat = min(self.bounds.size.width, self.bounds.size.height)
    lazy var radiusBase: CGFloat = CGFloat(roundf(Float(shortestSide) / 2))
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
        // adding animated circles
        for _ in 0...(Constants.linesCount - 1) {
            let tapeLayer = TapeLayer()
            tapeLayer.didFinishAnimation = { [weak self] layer in
                self?.didFinishAnimation(layer: layer)
            }
            tapeLayer.frame = bounds
            let circlePath = UIBezierPath(arcCenter:  CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: radiusBase - CGFloat(Constants.tapeWidth / 2), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            tapeLayer.path = circlePath.cgPath
            
            layers.append(tapeLayer)
            
            tapeLayer.shadowOffset = CGSize(width: 0, height: 0)
            tapeLayer.shadowRadius = 10
            tapeLayer.shadowColor = Constants.gradientColor3
            tapeLayer.shadowOpacity = 0.8
            
            let gradient = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = [Constants.gradientColor1,
                               Constants.gradientColor2,
                               Constants.gradientColor3,
                               Constants.gradientColor4]
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            gradient.mask = tapeLayer

            layer.addSublayer(gradient)
        }
        path = buildPath(points: Constants.pointsCount)
        
        // add central circle
        let circlePath = UIBezierPath(arcCenter:  CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: radiusBase - CGFloat(Constants.tapeWidth / 2), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
            
        // Change the fill color
        circleLayer.fillColor = UIColor.black.cgColor
        circleLayer.strokeColor = Constants.gradientColor4
        circleLayer.lineWidth = 1.0
        circleLayer.shadowOffset = CGSize(width: 0, height: 0)
        circleLayer.shadowRadius = 7
        circleLayer.shadowColor = Constants.gradientColor3
        circleLayer.shadowOpacity = 0.5
        layer.addSublayer(circleLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didFinishAnimation(layer: TapeLayer) {
        if layer == layers.first {
            path = buildPath(points: Constants.pointsCount)
        }
        layer.animateNewPath(newPath: path, layer: layer)
    }
    
    func startAnimating() {
        path = buildPath(points: Constants.pointsCount)
        
        var timeInterval: TimeInterval = 0
        layers.forEach { [weak self] layer in
            if self?.layers.last != layer {
                Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] timer in
                    if let path = self?.path {
                        layer.animateNewPath(newPath: path, layer: layer)
                    }
                    
                }
                timeInterval = timeInterval + 0.1
            }
        }
    }
    
    func buildPath(points: Int) -> UIBezierPath {
        //build a closed path that is a distorted polygon.
        var path = UIBezierPath()
        
        delta += (Double.pi * 1.5 / Double(points))
        for step in 0...(points - 1) {
            
            //Step around a circle
            let angle = CGFloat(Double.pi * 2) / CGFloat(points) * CGFloat(step) + delta
            let radius = radiusBase - CGFloat.random(in: 0...Constants.tapeWidth)
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
