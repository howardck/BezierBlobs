//
//  SuperEllipseCalculator.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-17.
//

import Foundation
import SwiftUI

func sign(_ number: Double) -> Double {
     if number > 0 { return 1 }
     return number == 0 ? 0 : -1
 }

func calculateSuperEllipse(for numPoints: Int,
                           n: Double,
                           with axes: Axes) -> BaseCurvePairs
{
    var baseCurve : BaseCurvePairs = [(vertex: CGPoint, normal: CGVector)]()
    
    var i = 0
    for theta in stride(from: 0,
                        to: 2 * Double.pi,
                        by: 2 * Double.pi/Double(numPoints)) {
        let cosT = cos(theta)
        var sinT = sin(theta)

        if sinT == 0 { sinT = Model.VANISHINGLY_SMALL_DOUBLE }
        // else dX goes infinite at theta == 0 & we're forked. kludgy?
        
        let inverseN = 2.0/n // not named accurately, but whatever...

        let x = axes.a * pow(abs(cosT), inverseN) * sign(cosT)
        let y = axes.b * pow(abs(sinT), inverseN) * sign(sinT)
        
        let vertex = CGPoint(x: x, y: y)
        
        // the orthogonal (== normal) to the curve at this point
        let dX = axes.b * inverseN * pow(abs(sinT), (inverseN - 1)) * cosT
        let dY = axes.a * inverseN * pow(abs(cosT), (inverseN - 1)) * sinT
        
        // store the normal in unit-vector form. thank you
        // 10th-grade geometry, euclid, and similar triangles
        let hypotenuse = hypot(dX, dY)
        let normal = CGVector(dx: dX/hypotenuse, dy: dY/hypotenuse)
        
        baseCurve += [(vertex: vertex, normal: normal)]
        
        if Model.DEBUG_PRINT_VERTEX_NORMALS {
            debugPrint(i: i, theta: theta, vertex: vertex, normal: normal)
            i += 1
        }
    }
    return baseCurve
}

func debugPrint(i: Int, theta: Double, vertex: CGPoint, normal: CGVector) {

    print( "[\((i).format(fspec: "2"))]  " +
            "theta: {\(theta.format(fspec: "5.3"))}  {" +
            "x: \(vertex.x.format(fspec: "7.2")), " +
            "y: \(vertex.y.format(fspec: "7.2"))},  {" +
            "dX: \(normal.dx.format(fspec: "5.3")), " +
            "dY: \(normal.dy.format(fspec: "5.3"))}")
    
//        alternatively:
//        let i_s = "\(i.format(fspec: "2"))"
//        let theta_s = "\(theta.format(fspec: "5.3"))"
//        let x_s = "\(vertex.x.format(fspec:" 7.2"))"
//        let y_s = "\(vertex.y.format(fspec: "7.2"))"
//        let dx_s = "\(normal.dx.format(fspec: "5.3"))"
//        let dy_s = "\(normal.dy.format(fspec: "5.3"))"
//        print( "[\(i_s)] theta: {\(theta_s)} | {x: \(x_s), y: \(y_s)} | {dx: \(dx_s), dy: \(dy_s)}" )
}
