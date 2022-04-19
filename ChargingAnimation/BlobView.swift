//
//  BlobView.swift
//  ChargingAnimation
//
//  Created by Serg on 13.04.22.
//

import UIKit

class BlobView: UIView {

    enum Constants {
        static let linesCount = 20
        static let pointsCount = 12
        static let tapeWidth: CGFloat = 40
        static let gradientColor1 = UIColor(red: 0.5294, green: 0.1961, blue: 0.8667, alpha: 1).cgColor
        static let gradientColor2 = UIColor(red: 0.4235, green: 0.3529, blue: 0.9333, alpha: 1).cgColor
        static let gradientColor3 = UIColor(red: 0.4784, green: 0.2706, blue: 0.898, alpha: 1).cgColor
        static let gradientColor4 = UIColor(red: 0.2136, green: 0.1565, blue: 0.6063, alpha: 1).cgColor
    }

    var layers = [BlobLayer]()
    var path: UIBezierPath!
    var delta:CGFloat = 0
    lazy var shortest_side = min(self.bounds.size.width, self.bounds.size.height)
    lazy var radius_base: CGFloat = CGFloat(roundf(Float(shortest_side) / 2))
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
        for _ in 0...(Constants.linesCount - 1) {
            let blobLayer = BlobLayer()
            blobLayer.didFinishAnimation = { [weak self] layer in
                self?.didFinishAnimation(layer: layer)
            }
            blobLayer.frame = bounds
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: 0, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            blobLayer.path = circlePath.cgPath
            
            layers.append(blobLayer)
            
            blobLayer.shadowOffset = CGSize(width: 0, height: 0)
            blobLayer.shadowRadius = 10
            blobLayer.shadowColor = Constants.gradientColor3
            blobLayer.shadowOpacity = 0.8
            
            let gradient = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = [Constants.gradientColor1,
                               Constants.gradientColor2,
                               Constants.gradientColor3,
                               Constants.gradientColor4]
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            gradient.mask = blobLayer

            layer.addSublayer(gradient)
            
            
        }
        path = buildPath(points: Constants.pointsCount)
        
        let circlePath = UIBezierPath(arcCenter:  CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: radius_base - CGFloat(Constants.tapeWidth / 2), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
            
        // Change the fill color
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.strokeColor = Constants.gradientColor4
        shapeLayer.lineWidth = 1.0
        shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
        shapeLayer.shadowRadius = 7
        shapeLayer.shadowColor = Constants.gradientColor3
        shapeLayer.shadowOpacity = 0.5
        
        
//        let gradient = CAGradientLayer()
//        gradient.frame = bounds
//        gradient.colors = [Constants.gradientColor1,
//                           Constants.gradientColor2,
//                           Constants.gradientColor3,
//                           Constants.gradientColor4]
//        gradient.startPoint = CGPoint(x: 0, y: 1)
//        gradient.endPoint = CGPoint(x: 1, y: 0)
//        gradient.mask = shapeLayer

  //      layer.addSublayer(shapeLayer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didFinishAnimation(layer: BlobLayer) {
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
        var randomPoints = [CGPoint]()
        var path = UIBezierPath()
        
        

        var angle: CGFloat = 0
        var radius: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var aPoint = CGPoint.zero
        
        delta += (Double.pi * 1.5 / Double(points))
        for step in 0...(points - 1) {
            
            //Step around a circle
            angle = CGFloat(Double.pi * 2) / CGFloat(points) * CGFloat(step) + delta
            
            //randomize the angle slightly
            
           // angle += Double.random(in: 0...(Double.pi / Double(Constants.pointsCount)))
//            if (step % 2) == 0 {
//                radius = radius_base
//            } else {
//                radius = radius_base - Constants.tapeWidth
//            }
            radius = radius_base - CGFloat.random(in: 0...Constants.tapeWidth)
            x = CGFloat(roundf(Float(CGFloat(cosf(Float(angle))) * radius + CGFloat(frame.size.width / 2))))
            y = CGFloat(roundf(Float(CGFloat(sinf(Float(angle))) * radius + CGFloat(frame.size.height / 2))))
            
            aPoint = CGPoint(x: x, y: y)
            randomPoints.append(aPoint)
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
