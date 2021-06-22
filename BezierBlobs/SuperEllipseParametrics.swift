//  SEParametrics.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-17.
//

import Foundation
import SwiftUI

struct SEParametrics {
    
    static let VANISHINGLY_SMALL_DOUBLE = 0.000000000000000001

    static func calculateSuperEllipse(for numPoints: Int,
                                      n: Double,
                                      with axes: Axes) -> BaseCurvePairs
    {
        var baseCurve : BaseCurvePairs = [(vertex: CGPoint, normal: CGVector)]()
        
        if DEBUG.PRINT_VERTEX_NORMALS { print("Vertex + Normals:") }
        
        var i = 0
        for theta in stride(from: 0,
                            to: 2 * Double.pi,
                            by: 2 * Double.pi/Double(numPoints)) {
            let cosT = cos(theta)
            var sinT = sin(theta)

            // otherwise dX goes infinite @ theta == 0 and we're forked.
            // kludge or clever? only her hairdresser knows for sure.
            if sinT == 0 {
                sinT = SEParametrics.VANISHINGLY_SMALL_DOUBLE
            }

            let inverseN = 2.0/n // not named accurately but whatever...

            let x = axes.a * pow(abs(cosT), inverseN) * sign(cosT)
            let y = axes.b * pow(abs(sinT), inverseN) * sign(sinT)
            
            let vertex = CGPoint(x: x, y: y)
            
            // the orthogonal (ie normal) to the curve at this point
            let dX = axes.b * inverseN * pow(abs(sinT), (inverseN - 1)) * cosT
            let dY = axes.a * inverseN * pow(abs(cosT), (inverseN - 1)) * sinT
            
            // store the normal in unit-vector form. thank you
            // euclid, 10th-grade geometry, and similar triangles!
            let hypotenuse = hypot(dX, dY)
            let normal = CGVector(dx: dX/hypotenuse, dy: dY/hypotenuse)
            
            // to demonstrate that our normal is a unit vector: dx*dx + dy*dy = 1
            //print("dx: \(  (normal.dx).format(fspec: "4.4"))  dy: \((normal.dx).format(fspec: "4.4")) ")
            //print("HYPOT: \(  ((normal.dx * normal.dx) + (normal.dy * normal.dy) ).format(fspec: "4.4"))")

            baseCurve += [(vertex: vertex, normal: normal)]
            
            if DEBUG.PRINT_VERTEX_NORMALS {
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
