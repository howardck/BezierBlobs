//
//  Path+Points.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-06-09.
//

import SwiftUI

extension Int {
    func isEven() -> Bool { self % 2 == 0 }
}

extension CGPoint {
    func newPoint(at offset: CGFloat,
                  along normal: CGVector) -> CGPoint
    {
        CGPoint(x: self.x + (offset * normal.dx),
                y: self.y + (offset * normal.dy))
    }
}

extension Path {
    
    mutating func addMarker(of radius: CGFloat) {
        let r = CGRect(x: currentPoint!.x,
                       y: currentPoint!.y,
                       width: radius, height: radius)
        self.addEllipse(in: r.offsetBy(dx: -radius/2, dy: -radius/2))
    }
    
    /* numInterpolated == granularity */
    func smoothed(numInterpolated: Int) -> Path
    {
        var smoothed = Path()
        var points = self.verticesOnly()
        
        // fix up the sequence so we can properly
        // interpolate across the vertex[0] origin
    
        let last = points[points.count - 1]
        points.append(points[0])
        points.append(points[1])
        points.insert(last, at: 0)
        
        for i in 1..<points.count - 2 {
            let (P0, P1, P2, P3) = (points[i-1], points[i], points[i+1], points[i+2])
            
            i == 1 ?
                smoothed.move(to: P1) :
                smoothed.addLine(to: P1)
            
            let numInterp = CGFloat(numInterpolated + 1)
            for j in 1...numInterpolated {
                let t = CGFloat(j)/numInterp
                let ip = self.interpolatedPoint(CP0: P0, p1: P1, p2: P2, CP3: P3, t: t)
                smoothed.addLine(to: ip)
            }
            smoothed.addLine(to: P2)
        }
        return smoothed
    }
    
    /*  a moving 4-point viewport that slides along our curve
        one vertex at a time, with P1 = vertex[n], P2 = vertex[n+1],
        and P0 and P3 as control points CP0 and CP3.
        we interpolate <numIterpolated> new points between P1 and P2.
        rinse and repeat until we've interpolated between all vertex pairs.
    */
    func interpolatedPoint(CP0: CGPoint, p1: CGPoint, p2: CGPoint, CP3: CGPoint, t: CGFloat) -> CGPoint
    {
        let t2 = t * t
        let t3 = t2 * t
        
        // via sadun et al ...
        let x = 0.5 * (2*p1.x+(p2.x-CP0.x)*t + (2*CP0.x-5*p1.x+4*p2.x-CP3.x)*t2 + (3*p1.x-CP0.x-3*p2.x+CP3.x)*t3)
        let y = 0.5 * (2*p1.y+(p2.y-CP0.y)*t + (2*CP0.y-5*p1.y+4*p2.y-CP3.y)*t2 + (3*p1.y-CP0.y-3*p2.y+CP3.y)*t3)
        
        return CGPoint(x: x, y: y)
    }
    
    // decompose the path into its constituent vertices
    // ( used to be a lot harder and baroque/opaque in objective-c!
    func verticesOnly() -> [CGPoint] {
        var points = [CGPoint]()
        self.forEach { element in
            switch element {
            case .closeSubpath:
                break
            case .curve(let to, _, _) :
                points.append(to)
            case .line(let to) :
                points.append(to)
            case .move(let to) :
                points.append(to)
            case .quadCurve(let to, _) :
                points.append(to)
            }
        }
//    print("\nextension Path.verticesOnly():"
//        + " {\(points.count)} points")
//    print("boundingRect: {\(self.boundingRect)}")
//
//    for (ix, pt) in points.enumerated() {
//        print("[\(ix)]: {" +
//            "x: \(pt.x.format(f: ".4")) " +
//            "y: \(pt.y.format(f: ".4"))}")
//    }
        
        return points
    }
        
    // scale the path to fit (as opposed to fill)
    func scaled(toFit rect: CGRect) -> Path {
        let scaleW = rect.width/boundingRect.width
        let scaleH = rect.height/boundingRect.height
        let scaleFactor = min(scaleW, scaleH)
        
        return applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
    }
}
