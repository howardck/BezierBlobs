//
//  Model.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

typealias Axes = (a: Double, b: Double)
typealias Offsets = (in: CGFloat, out: CGFloat)
typealias BoundingCurves = (inner: [CGPoint], outer: [CGPoint])
typealias ZigZagCurves = (zig: [CGPoint], zag: [CGPoint])

class Model: ObservableObject {
    
    // zig configuration starts to the inside at point 0
    // zag configuration starts to the outside
    var animateToZigConfiguration = false
    
    static let DEBUG_PRINT = false
    static let VANISHINGLY_SMALL_DOUBLE = 0.000000000000000001
        
    @Published var blobCurve = [CGPoint]()
    
    var axes : Axes = (1, 1)
    
    var baseCurve = [CGPoint]()
    var normals = [CGVector]()
    
    var baseCurvePlusNormals = [(CGPoint, CGVector)]()
    
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]())
    
    //MARK: TODO: OFFSETS SHOULD BE A PLATFORM-SPECIFIC SCREEN RATIO
    var offsets : Offsets = (in: 0, out: 0)
    var order: Double = 0.0
    
    //MARK: -
    func animateToNextZigZagPosition() {
        
        blobCurve = animateToZigConfiguration ?
            zigZagCurves.zig :
            zigZagCurves.zag
        
        animateToZigConfiguration.toggle()
    }
    
    //MARK: -
    
    func calculateSuperEllipseCurves(for pageId: Int,
                                     pageDescription: PageDescription,
                                     axes: Axes) {
        
        let radius = CGFloat((axes.a + axes.b)/2.0)
        
        let numPoints = pageDescription.numPoints
        offsets = (in: radius * pageDescription.offsets.in,
                   out: radius * pageDescription.offsets.out)
        order = pageDescription.order
        
        if pageDescription.forceEqualAxes {
            let minab = min(axes.a, axes.b)
            self.axes = (a: minab, b: minab)
        }
        else {
            self.axes = axes
        }

        let stuff = calculateBaseCurvePlus(for: numPoints, with: self.axes)
        
        if (true) {
            print("\nModel.calculateSuperEllipseCurves(pageId: [\(pageId)] numPoints: {\(numPoints)} ...)")
            print("axes: a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))}")
        }
        
        baseCurve = stuff.baseCurve
        normals = stuff.normals
        
        boundingCurves = calculateBoundingCurves(offsets: self.offsets)
        zigZagCurves = calculateZigZagCurves(offsets: self.offsets)
        
        // our initial visual configuration
         //blobCurve = baseCurve
        
        self.animateToNextZigZagPosition()
    }
    
    func calculateZigZagCurves(offsets: Offsets) -> ZigZagCurves {
        // z.enumerated(() => ($0.0: Int, ($0.1.0: CGPoint, $0.1.1: CGVector))
        let z = zip(baseCurve,normals)
        let zigCurve = z.enumerated().map {
            $0.1.0.newPoint(at: $0.0.isEven() ? offsets.in : offsets.out,
                            along: $0.1.1)
        }
        let zagCurve = z.enumerated().map {
            $0.1.0.newPoint(at: $0.0.isEven() ? offsets.out : offsets.in,
                            along: $0.1.1)
        }
        return (zigCurve, zagCurve)
    }
    
    // define an envelope within which our blob does it thing, ie zigs and zags.
    func calculateBoundingCurves(offsets: Offsets) -> BoundingCurves {
        let z = zip(baseCurve, normals)
        return (inner: z.map{ $0.0.newPoint(at: offsets.in, along: $0.1) },
                outer: z.map{ $0.0.newPoint(at: offsets.out, along: $0.1) })
    }
    
    func calculateBaseCurvePlus(for numPoints: Int,
                                with axes: Axes) -> (baseCurve:[CGPoint],
                                                     normals: [CGVector])
    {
        var baseCurve = [CGPoint]()
        var normals = [CGVector]()
        
        var i = 0
        for theta in stride(from: 0,
                            to: 2 * Double.pi,
                            by: 2 * Double.pi/Double(numPoints))
        {
            let cosT = cos(theta)
            var sinT = sin(theta)

            if sinT == 0 { sinT = Model.VANISHINGLY_SMALL_DOUBLE }
            // else dX goes infinite at theta == 0 & we're forked. kludge?
            
            let inverseOrder = 2.0/order // not really an inverse but whatever...

            let x = axes.a * pow(abs(cosT), inverseOrder) * sign(cosT)
            let y = axes.b * pow(abs(sinT), inverseOrder) * sign(sinT)
            
            let vertex = CGPoint(x: x, y: y)
            baseCurve += [vertex]
            
            // and the orthogonal (ie normal) to it at that point
            let dX = inverseOrder * pow(abs(sinT), (inverseOrder - 1)) * cosT
            let dY = inverseOrder * pow(abs(cosT), (inverseOrder - 1)) * sinT
            
            // store the normal in unit-vector form. thank you
            // 10th-grade geometry, euclid, and similar triangles!
            let normal = CGVector(dx: dX/hypot(dX, dY), dy: dY/hypot(dX, dY))
            normals += [normal]
            
            if Model.DEBUG_PRINT {
                debugPrint(i: i, theta: theta, vertex: vertex, normal: normal)
                i += 1
            }
        }
        return (baseCurve, normals)
    }
    
    func sign(_ number: Double) -> Double {
         if number > 0 { return 1 }
         return number == 0 ? 0 : -1
     }
    
    func debugPrint(i: Int, theta: Double, vertex: CGPoint, normal: CGVector) {

        print( "[\((i).format(fspec: "2"))]  " +
                "theta: {\((theta).format(fspec: "5.3"))}  {" +
                "x: \((vertex.x).format(fspec: "7.2")), " +
                "y: \((vertex.y).format(fspec: "7.2"))},  {" +
                "dX: \((normal.dx).format(fspec: "5.3")), " +
                "dY: \((normal.dy).format(fspec: "5.3"))}")
        
//        alternatively ...
//        let i_s = "\((i).format(fspec: "2"))"
//        let theta_s = "\((theta).format(fspec: "5.3"))"
//        let x_s = "\((vertex.x).format(fspec:" 7.2"))"
//        let y_s = "\((vertex.y).format(fspec: "7.2"))"
//        let dx_s = "\((normal.dx).format(fspec: "5.3"))"
//        let dy_s = "\((normal.dy).format(fspec: "5.3"))"
//        print( "[\(i_s)] theta: {\(theta_s)} | {x: \(x_s), y: \(y_s)} | {dx: \(dx_s), dy: \(dy_s)}" )
    }
}
