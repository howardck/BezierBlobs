//
//  DEBUG.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-17.
//

import SwiftUI

struct DEBUG {
    
    static func printBasicPageInfo(pageType: PageDescriptors.PageType,
                                   numPoints: Int,
                                   size: CGSize,
                                   axes: (a: Double, b: Double)) {
        
        print("PageView.init( {PageType.\(pageType)} ): \n" +
                "   numPoints: {\(numPoints)} {" +
                "W: \((size.width).format(fspec: "4.2")), " +
                "H: \((size.height).format(fspec: "4.2"))}")
        print("   semiMinorAxis {a: \(axes.a)} semiMajorAxis {b: \(axes.b)}")
    }
    
    static func printOffsetAndPerturbationData(pageType: PageDescriptors.PageType,
                                               offsets: Offsets,
                                               ranges: PerturbationDeltas) {
    
        print("PageView.init( {PageType.\(pageType)} ): \n" +
                "   model.offsets : " +
                "(inner: [\(offsets.inner.format(fspec: "4.2"))] <—-|-—> " +
                "outer: [\(offsets.outer.format(fspec: "4.2"))]) ")
        
        print("   perturbationRanges: inner: (\(ranges.innerRange.lowerBound)..< \(ranges.innerRange.upperBound)) <—-|-—> " +
                "outer: (\(ranges.outerRange.lowerBound)..< \(ranges.outerRange.upperBound))")
    
    }
    
    static func printNormalsInfo(i: Int,
                                 theta: Double,
                                 vertex: CGPoint,
                                 normal: CGVector) {
        
        print( "[\((i).format(fspec: "2"))] " +
                "theta: {\(theta.format(fspec: "5.3"))}  {" +
                "x: \(vertex.x.format(fspec: "7.2")), " +
                "y: \(vertex.y.format(fspec: "7.2"))},  {" +
                "dX: \(normal.dx.format(fspec: "5.3")), " +
                "dY: \(normal.dy.format(fspec: "5.3"))}")
        
            /*
            alternatively:
                let i_s = "\(i.format(fspec: "2"))"
                let theta_s = "\(theta.format(fspec: "5.3"))"
                let x_s = "\(vertex.x.format(fspec:" 7.2"))"
                let y_s = "\(vertex.y.format(fspec: "7.2"))"
                let dx_s = "\(normal.dx.format(fspec: "5.3"))"
                let dy_s = "\(normal.dy.format(fspec: "5.3"))"
                print( "[\(i_s)] theta: {\(theta_s)} | {x: \(x_s), y: \(y_s)} | {dx: \(dx_s), dy: \(dy_s)}" )
            */
    }
}
