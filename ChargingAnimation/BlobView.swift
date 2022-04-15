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
        static let pointsCount = 10
    }

    var layers = [BlobLayer]()
    var path: UIBezierPath!
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
            blobLayer.frame = frame
    //        blobLayer.path = buildPath(points: Constants.pointsCount).cgPath
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: blobLayer.frame.size.width / 2, y: blobLayer.frame.size.width / 2), radius: 0, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            blobLayer.path = circlePath.cgPath
            
            layers.append(blobLayer)
            
            blobLayer.shadowOffset = CGSize(width: 0, height: 0)
            blobLayer.shadowRadius = 6
            blobLayer.shadowColor = UIColor.green.cgColor
            blobLayer.shadowOpacity = 0.5
            
            let gradient = CAGradientLayer()
            gradient.frame = frame
            gradient.colors = [UIColor(red: 0.5294, green: 0.1961, blue: 0.8667, alpha: 1).cgColor,
                               UIColor(red: 0.4235, green: 0.3529, blue: 0.9333, alpha: 1).cgColor,
                               UIColor(red: 0.4784, green: 0.2706, blue: 0.898, alpha: 1).cgColor,
                               UIColor(red: 0.2136, green: 0.1565, blue: 0.6063, alpha: 1).cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            gradient.mask = blobLayer

            layer.addSublayer(gradient)
            
            
        }
        path = buildPath(points: Constants.pointsCount)
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
        var delay: Double = 0
        path = buildPath(points: Constants.pointsCount)
        let time: DispatchTime = .now()
        layers.forEach { layer in
            DispatchQueue.main.asyncAfter(deadline: time + delay) { [weak self] in
                if let path = self?.path {
                    layer.animateNewPath(newPath: path, layer: layer)
                }
                
            }
            delay += 0.5
        }
    }
    
    func buildPath(points: Int) -> UIBezierPath {
        //build a closed path that is a distorted polygon.
        var randomPoints = [CGPoint]()
        var path = UIBezierPath()
        
        

        var angle: CGFloat = 0
        var radius: CGFloat = 0
        var step: Int = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var aPoint = CGPoint.zero
        
          
        for step in 0...(points - 1) {
            
            //Step around a circle
            angle = CGFloat(Double.pi * 2) / CGFloat(points) * CGFloat(step) + (Double.pi / 4 * 2);
            
            //randomize the angle slightly
            
            var random_val: CGFloat = randomFloatPlusOrMinus(max_value: Double.pi / Double(points) * 0.1)
            angle += random_val
            
            
            radius = radius_base
            random_val = randomFloatPlusOrMinus(max_value: radius_base / 3)
            radius += random_val
            x = CGFloat(roundf(Float(CGFloat(cosf(Float(angle))) * radius + CGFloat(shortest_side / 2))))
            y = CGFloat(roundf(Float(CGFloat(sinf(Float(angle))) * radius + CGFloat(shortest_side / 2))))
            
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
        path = path.smoothedPath(16)
        return path
    }
    
    func randomFloatPlusOrMinus(max_value: CGFloat) -> CGFloat {
       return randomFloat(max_value: (max_value * 1)) - max_value
    }
    
    func randomFloat(max_value: CGFloat) -> CGFloat {
        var aRandom: CGFloat = CGFloat((arc4random() % 1000000001)) / 2
        aRandom = (aRandom * max_value) / 1000000000
        return aRandom
    }
}
