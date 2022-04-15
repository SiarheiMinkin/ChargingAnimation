//
//  UIBezierPath+Extension.swift
//  ChargingAnimation
//
//  Created by Serg on 15.04.22.
//

import Foundation
import UIKit
import CoreGraphics

extension UIBezierPath {
    
    func pathIsClosed() -> Bool {
        var pathIsClosed = false
        cgPath.apply(info: &pathIsClosed, function: { info, element in
            guard let subPathIsClosed = info?.assumingMemoryBound(to: Bool.self) else {
                return
            }
            // Retrieve the path element type and its points
            let type = element.pointee.type
            
            // Add the points if they're available (per type)
            if (type == .closeSubpath)
            {
                subPathIsClosed.pointee = true
                return
            }
        })
        return pathIsClosed
    }

    
    func smoothedPath(granularity: Int) -> UIBezierPath? {
        guard let points: NSMutableArray = self.points() else {return nil}
        let pathIsClosed = pathIsClosed()
        if points.count < 4 {return (self.copy() as! UIBezierPath)}
        if !pathIsClosed {
            points.insert([points[0]], at: 0)
            points.add(points.lastObject)
        }
        
        let smoothedPath = UIBezierPath()
        // Copy traits
        smoothedPath.lineWidth = self.lineWidth
        // Draw out the first 3 points (0..2)
        
        smoothedPath.move(to:(points[0] as! NSValue).cgPointValue)
        
        if !pathIsClosed {
            smoothedPath.addLine(to: (points[1] as! NSValue).cgPointValue)
        }
        var start = 3
        var end = points.count
        if pathIsClosed
        {
          start -= 1
          end += 2
        }
        
        for index in start..<end {
            let p0 = (points[(points.count + index - 3) % points.count] as! NSValue).cgPointValue
            let p1 = (points[(points.count + index - 2) % points.count] as! NSValue).cgPointValue
            let p2 = (points[(points.count + index - 1) % points.count] as! NSValue).cgPointValue
            let p3 = (points[index % points.count] as! NSValue).cgPointValue
          
            // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
            for i in 1..<granularity {
                let t = Float(i) * (1.0 / Float(granularity))
                let tt = t * t
                let ttt = tt * t
                var pi = CGPoint() // intermediate point
           
                let expX1: CGFloat = 2 * p1.x + (p2.x - p0.x) * CGFloat(t)
                let expX2: CGFloat = (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * CGFloat(tt)
                let expX3: CGFloat = 3 * p1.x - p0.x - 3 * p2.x + p3.x
                pi.x = (expX1 + expX2 + expX3 * CGFloat(ttt)) * 0.5
                
                let expY1 = 2 * p1.y + (p2.y - p0.y) * CGFloat(t)
                let expY2 = (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * CGFloat(tt)
                let expY3 = (3 * p1.y - p0.y - 3 * p2.y + p3.y) * CGFloat(ttt)
                pi.y = (expY1 + expY2 + expY3) * 0.5
                smoothedPath.addLine(to: pi)
            }
            
            // Now add p2
            smoothedPath.addLine(to: p2)
        }
        
        // finish by adding the last point
        if !pathIsClosed {
            smoothedPath.addLine(to: (points[points.count - 1] as! NSValue).cgPointValue)
        }
         
        if pathIsClosed {
            smoothedPath.close()
        }
          
        return smoothedPath;
    }
    
    
    func points() -> NSMutableArray? {
        var bezierPoints = NSMutableArray()
        cgPath.apply(info: &bezierPoints, function: { info, element in
            
            
            guard let resultingPoints = info?.assumingMemoryBound(to: NSMutableArray.self) else {
                        return
                    }
            
                        // Retrieve the path element type and its points
                        let type = element.pointee.type
                        let points = element.pointee.points
            
                        // Add the points if they're available (per type)
                        if (type != .closeSubpath)
                        {
                            resultingPoints.pointee.addObjects(from: [NSValue.init(cgPoint: points[0])])
                            if ((type != .addLineToPoint) &&
                                (type != .moveToPoint)) {
                                resultingPoints.pointee.addObjects(from: [NSValue.init(cgPoint: points[1])])
                            }
                        }
                        if (type == .addCurveToPoint) {
                            resultingPoints.pointee.addObjects(from: [NSValue.init(cgPoint: points[2])])
                        }
        })
        return bezierPoints
    }
    
}
