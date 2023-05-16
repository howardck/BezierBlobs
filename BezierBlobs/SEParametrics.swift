//
//  SEParametrics.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-17.
//

import Foundation
import SwiftUI

struct SEParametrics {
    
    static let VANISHINGLY_SMALL_DOUBLE = 0.000000000000000001

    static func calculateSuperEllipse(order: Double,
                                      for numPoints: Int,
                                      with axes: Axes) -> [(vertex: CGPoint, normal: CGVector)]
    {
        let ε = 2.0/order
        
        var baseCurve : BaseCurveTuples = [(vertex: CGPoint, normal: CGVector)]()
                
        if DEBUG.PRINT_VERTICES_AND_NORMALS { print("[[ VERTICES + NORMALS ]]:") }
        
        var i = 0
        for theta in stride(from: 0,
                            to: 2 * Double.pi,
                            by: 2 * Double.pi/Double(numPoints)) {
            let cosT = cos(theta)
            var sinT = sin(theta)
            
            // otherwise dX goes infinite at theta == 0 and we're forked
            if sinT == 0 { sinT = SEParametrics.VANISHINGLY_SMALL_DOUBLE }
            
            let x = axes.a * pow(abs(cosT), ε) * sign(cosT)
            let y = axes.b * pow(abs(sinT), ε) * sign(sinT)
            
            let vertex = CGPoint(x: x, y: y)
            
            // the orthogonal vector (ie normal) to the curve at this point
            
            let dX = axes.b * ε * pow(abs(sinT), (ε - 1)) * cosT
            let dY = axes.a * ε * pow(abs(cosT), (ε - 1)) * sinT
            
            // store in unit vector form. thank you euclid,
            // 10th-grade geometry, and similar triangles!
            let hypotenuse = hypot(dX, dY)
            let normal = CGVector(dx: dX/hypotenuse, dy: dY/hypotenuse)
            
            /*  visually confirm that the normal is a unit vector;
                ie dx*dx + dy*dy == 1 for all vertices

                let HYP = ((normal.dx * normal.dx) + (normal.dy * normal.dy) )
                print("dx: \(  (normal.dx).format(fspec: "7.4"))  "
                       + "dy: \((normal.dx).format(fspec: "7.4"))  "
                       + "HYP: \(  HYP.format(fspec: "7.4"))" )
             */
            
            baseCurve += [(vertex: vertex, normal: normal)]
            
            if DEBUG.PRINT_VERTICES_AND_NORMALS {
                DEBUG.printNormalsInfo(i: i, theta: theta, vertex: vertex, normal: normal)
                i += 1
            }
        }
        
        return baseCurve
    }
    
    static func sign(_ number: Double) -> Double {
         if number > 0 { return 1 }
         return number == 0 ? 0 : -1
     }


}
