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
typealias BaseCurve = (vertices: [CGPoint], normals: [CGVector])

class Model: ObservableObject {
    
    @Published var blobCurve = [CGPoint]()
    
    // at point 0
    // zig configuration starts to the inside
    // zag configuration starts to the outside
    var animateToZigConfiguration = false
    
    static let DEBUG_PRINT = true
    // kludge ahoy?!
    static let VANISHINGLY_SMALL_DOUBLE = 0.000000000000000001
    
    var axes : Axes = (1, 1)
    
    //var baseCurveVertices = [CGPoint]()
    //var normals = [CGVector]()
    
    var baseCurve : BaseCurve = (vertices: [CGPoint](), normals: [CGVector]())
    
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]())
    
    //MARK: TODO: OFFSETS SHOULD BE A PLATFORM-SPECIFIC SCREEN RATIO
    var offsets : Offsets = (in: 0, out: 0)
    var n: Double = 0.0
    
    //MARK: -
    func animateToNextZigZagPhase() {
        
        blobCurve = animateToZigConfiguration ?
            zigZagCurves.zig :
            zigZagCurves.zag
        
        animateToZigConfiguration.toggle()
    }
    
    //MARK: -
    
    func calculateSuperEllipseCurves(for pageType: PageType,
                                     pageDescription: PageDescription,
                                     axes: Axes) {
        
        let radius = CGFloat((axes.a + axes.b)/2.0)
        
        let numPoints = pageDescription.numPoints
        offsets = (in: radius * pageDescription.offsets.in,
                   out: radius * pageDescription.offsets.out)
        n = pageDescription.n
        
        self.axes = axes
        if pageDescription.forceEqualAxes {
            let minab = min(axes.a, axes.b)
            self.axes = (a: minab, b: minab)
        }

        self.baseCurve = calculateBaseCurvePlus(for: numPoints, with: self.axes)
        
        if (true) {
            print("\nModel.calculateSuperEllipseCurves(pageId: [\(pageType)] numPoints: {\(numPoints)} ...)")
            print("axes: a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))}")
        }
        
        boundingCurves = calculateBoundingCurves(offsets: self.offsets)
        zigZagCurves = calculateZigZagCurves(offsets: self.offsets)
        
        self.animateToNextZigZagPhase()
    }
    
    // these two curves define the two extremes our blob path animates between
    func calculateZigZagCurves(offsets: Offsets) -> ZigZagCurves {
        // z.enumerated(() => ($0.0: Int, ($0.1.0: CGPoint, $0.1.1: CGVector))
        let z = zip(baseCurve.vertices, baseCurve.normals)
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
    
    // define an envelope within which our blob
    // does it thing, ie zigs and zags.
    func calculateBoundingCurves(offsets: Offsets) -> BoundingCurves {
        let z = zip(baseCurve.vertices, baseCurve.normals)
        return (inner: z.map{ $0.0.newPoint(at: offsets.in, along: $0.1) },
                outer: z.map{ $0.0.newPoint(at: offsets.out, along: $0.1) })
    }
    
    func calculateNormalsPseudoCurve() -> [CGPoint] {
        var normals = [CGPoint]()
        for i in 0..<boundingCurves.inner.count {
            normals.append(boundingCurves.inner[i])
            normals.append(boundingCurves.outer[i])
        }
        return normals
    }
    
    func calculateBaseCurvePlus(for numPoints: Int,
                                with axes: Axes) -> (vertices:[CGPoint],
                                                     normals: [CGVector])
    {
        var baseCurve = (vertices: [CGPoint](), normals: [CGVector]())
        var i = 0
        for theta in stride(from: 0,
                            to: 2 * Double.pi,
                            by: 2 * Double.pi/Double(numPoints))
        {
            let cosT = cos(theta)
            var sinT = sin(theta)

            if sinT == 0 { sinT = Model.VANISHINGLY_SMALL_DOUBLE }
            // else dX goes infinite at theta == 0 & we're forked. kludge?
            
            let inverseN = 2.0/n // not really named accurately, but whatever...

            let x = axes.a * pow(abs(cosT), inverseN) * sign(cosT)
            let y = axes.b * pow(abs(sinT), inverseN) * sign(sinT)
            
            let vertex = CGPoint(x: x, y: y)
            baseCurve.vertices += [vertex]
            
            // and the orthogonal (ie normal) to it at that point
            let dX = axes.b * inverseN * pow(abs(sinT), (inverseN - 1)) * cosT
            let dY = axes.a * inverseN * pow(abs(cosT), (inverseN - 1)) * sinT
            
            // store the normal in unit-vector form. thank you
            // 10th-grade geometry, euclid, and similar triangles
            let hypotenuse = hypot(dX, dY)
            let normal = CGVector(dx: dX/hypotenuse, dy: dY/hypotenuse)
            baseCurve.normals += [normal]
            
            if Model.DEBUG_PRINT {
                debugPrint(i: i, theta: theta, vertex: vertex, normal: normal)
                
//                let div = dY/dX
                //print( "dY/dX: [\((div).format(fspec: "5.3"))]  ")
                //print("")
                i += 1
            }
        }
        return baseCurve
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
        
//        alternatively 
//        let i_s = "\((i).format(fspec: "2"))"
//        let theta_s = "\((theta).format(fspec: "5.3"))"
//        let x_s = "\((vertex.x).format(fspec:" 7.2"))"
//        let y_s = "\((vertex.y).format(fspec: "7.2"))"
//        let dx_s = "\((normal.dx).format(fspec: "5.3"))"
//        let dy_s = "\((normal.dy).format(fspec: "5.3"))"
//        print( "[\(i_s)] theta: {\(theta_s)} | {x: \(x_s), y: \(y_s)} | {dx: \(dx_s), dy: \(dy_s)}" )
    }
}
