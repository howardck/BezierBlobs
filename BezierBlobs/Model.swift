//
//  Model.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

typealias Axes = (a: Double, b: Double)
typealias Offsets = (inner: CGFloat, outer: CGFloat)
typealias BoundingCurves = (inner: [CGPoint], outer: [CGPoint])
typealias ZigZagCurves = (zig: [CGPoint], zag: [CGPoint])
typealias BaseCurveType = (vertices: [CGPoint], normals: [CGVector])

class Model: ObservableObject { // init() { print("Model.init()") }
    
    @Published var blobCurve = [CGPoint]()
    
    // at vertex 0:
    // zig configuration starts to the outside
    // zag configuration starts to the inside
    
    // go to the outside (== ZIG) first
    var animateToZigPhase = true
    
    static let DEBUG_PRINT_COORDS = false
    static let DEBUG_TRACK_ZIGZAG_PHASING = false
    static let DEBUG_PRINT_OFFSET_CALCS = true
    
    static let VANISHINGLY_SMALL_DOUBLE = 0.000000000000000001  // kludge ahoy?
    
    var axes : Axes = (1, 1)

    // MARK:-
    // TODO: SEE NOTE in baseCurvePlusNormals() on possibly recasting as:
    // TODO: var baseCurve: ([(vertex: CGPoint, normal: CGVector)]
    
    // MARK:-
    var baseCurve : BaseCurveType = (vertices: [CGPoint](), normals: [CGVector]())
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]())
    var normalsCurve : [CGPoint] = [CGPoint]()
    
    //MARK:-
    //TODO: TODO: OFFSETS SHOULD BE A PLATFORM-SPECIFIC SCREEN RATIO
    
    var offsets : Offsets = (inner: 0, outer: 0)
    var n: Double = 0.0
    
    //MARK: -
    func animateToNextZigZagPhase() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.animateToNextZigZagPhase():: animateToZig == {\(animateToZigPhase)}")
        }
        
        blobCurve = animateToZigPhase ?
            randomlyPermuted(zzCurve: zigZagCurves.zig) :
            randomlyPermuted(zzCurve: zigZagCurves.zag)
        
        animateToZigPhase.toggle()
    }
    
    func animateToCurrZigZagPhase() {
        blobCurve = animateToZigPhase ?
            zigZagCurves.zag :
            zigZagCurves.zig
    }
    
    func randomlyPermuted(zzCurve: [CGPoint]) -> [CGPoint]
    {
        // (1) build a list of in & out deltas for each vertex
        // (2) apply each delta along the normal at each vertex
            // to produce a new curve
        let permutations = randomizedPermutations(for: zzCurve)
        return applyList(of: permutations, to: zzCurve)
    }
    
    func randomizedPermutations(for zzCurve: [CGPoint]) -> [CGFloat]
    {
        // INITIALLY just start with 0's
        return Array(repeating: 0.0, count: zzCurve.count)
    }
    
    func applyList(of randomPermuations: [CGFloat], to zzCurve: [CGPoint]) -> [CGPoint] {
        // startin out with an unperturbed (ie original) curve
        zzCurve
    }
    
    //MARK: -
    
    var pageType: PageType?
    
    func calculateSuperEllipseCurves(for pageType: PageType,
                                     pageDescription: PageDescription,
                                     axes: Axes) {
        
        self.pageType = pageType // for debugging reference
        
        print("Model.calculateSuperEllipseCurves(): axes {a: \(axes.a), b: \(axes.b)}")
        
        // NOT SURE IF THIS IS THE BEST APPROACH HERE ...
        let radius = CGFloat((axes.a + axes.b)/2.0)
        
        let numPoints = pageDescription.numPoints
        offsets = (inner: radius * pageDescription.offsets.in,
                   outer: radius * pageDescription.offsets.out)
        n = pageDescription.n
        
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//        offsets.inner = -30
//        offsets.outer = 30
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

        self.axes = axes
        if pageDescription.forceEqualAxes {
            let minab = min(axes.a, axes.b)
            self.axes = (a: minab, b: minab)
        }

        self.baseCurve = calculateBaseCurvePlusNormals(for: numPoints,
                                                       with: self.axes)
        if Self.DEBUG_PRINT_OFFSET_CALCS {
            print("\nModel.calculateSuperEllipseCurves(PageType.\(pageType.rawValue))")
            //print("-------------------------------------")
            print("numPoints: {\(numPoints)} ")
            print("axes: (a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))})")
            print("offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
        }
        
        let innerRandomLimits = (-0.5, 1.0) // the inner offset can go 50% further in & 100% further out
        let outerRandomLimits = (-1.0, 0.5) // the outer offset can go 100% further in & 50% further out
        
        boundingCurves = calculateBoundingCurves(using: self.offsets)
        zigZagCurves = calculateZigZagCurves(using: self.offsets)
        normalsCurve = calculateNormalsPseudoCurve()
        
        if ContentView.StatusTracker.isUninitialzed(pageType: pageType) {
            setInitialBlobCurve()
            ContentView.StatusTracker.markInited(pageType: pageType)
        }
        else {
            animateToCurrZigZagPhase()
        }
    }
    
    func randomizeZigZagCurve(zigOrZag: [CGPoint], usingRandomizingRatio: (Double, Double)) -> [CGPoint]
    {
        
        return [CGPoint]()
    }
        
    func setInitialBlobCurve() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.setInitialBlobCurve(PageType.\(pageType!.rawValue))" )
        }
        
        blobCurve = baseCurve.vertices
    }
    
    func returnToInitialConfiguration() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.returnToInitialConfiguration(PageType.\(pageType!.rawValue))" )
        }
        
        blobCurve = baseCurve.vertices
    }
    
    // these define the two path extremes our
    // generated blob path animates between.
    func calculateZigZagCurves(using offsets: Offsets) -> ZigZagCurves {

        //TODO: TODO: EXPLORE USING ARRAY OF TUPLES FOR baseCurve

        /*  instead of baseCurve being defined as ([CGPoint], [CGVector]),
            it could easily be instantiated as [(CGPoint, CGVector)], which
            has several advantages:
            (1) they're in zipped form from the start; we don't need to zip here.
            (2) they're already in array form, so we don't need to do enumerated().
        */
        
        let zipped = zip(baseCurve.vertices, baseCurve.normals).enumerated()
        /*
         on enumerating a zipped array pair of vertices & their normals,
         a map{} function sees this:
         
            $0.0: index of the point
            $0.1: the vertex/normal pair for the point. ie
                $0.1.0: the vertex
                @0.1.1: the normal (a CGVector) of/at the point
         */
    
        // zip curve starts to the outside at vertex 0 (ie origin)
        let zigCurve = zipped.map {
            $0.1.0.newPoint(at: randomizedOffset(offset: $0.0.isEven() ?
                                                    offsets.outer :
                                                    offsets.inner),
                            along: $0.1.1)
        }
        let zagCurve = zipped.map {
            $0.1.0.newPoint(at: randomizedOffset(offset: $0.0.isEven() ?
                                                    offsets.inner :
                                                    offsets.outer),
                            along: $0.1.1)
        }
        return (zigCurve, zagCurve)
    }
    
    func randomizedOffset(offset: CGFloat) -> CGFloat {
        offset
//        if offset <= 0 {
//            // offset is on the inside;
//            let r = ((offset * 0.1)...(offset * 0.4))
//            return offset - CGFloat.random(in: r)
//        }
//        else {
//            let r = (offset * 0.1...offset * 0.4)
//            return offset + CGFloat.random(in: r)
//        }
    }
    
    func calculateNormalsPseudoCurve() -> [CGPoint] {
        var normals = [CGPoint]()
        for i in 0..<boundingCurves.inner.count {
            normals.append(boundingCurves.inner[i])
            normals.append(boundingCurves.outer[i])
        }
        return normals
    }
    
    // define an envelope w/in which our blob blobs
    
    func calculateBoundingCurves(using offsets: Offsets) -> BoundingCurves {
        let z = zip(baseCurve.vertices, baseCurve.normals)
        return (inner: z.map{ $0.0.newPoint(at: offsets.inner, along: $0.1) },
                outer: z.map{ $0.0.newPoint(at: offsets.outer, along: $0.1) })
    }
    
    // the basis of everything else ...
    func calculateBaseCurvePlusNormals(for numPoints: Int,
                                       with axes: Axes) -> (vertices:[CGPoint],
                                                            normals: [CGVector])
    {
        //TODO: TODO: look at trying ~ ([(vertex: CGPoint, normal: CGVector)]
        //TODO: TODO:
        var baseCurve = (vertices: [CGPoint](), normals: [CGVector]())
        var i = 0
        for theta in stride(from: 0,
                            to: 2 * Double.pi,
                            by: 2 * Double.pi/Double(numPoints)) {
            let cosT = cos(theta)
            var sinT = sin(theta)

            if sinT == 0 { sinT = Model.VANISHINGLY_SMALL_DOUBLE }
            // else dX goes infinite at theta == 0 & we're forked. kludgy?
            
            let inverseN = 2.0/n // not really named accurately, but whatever...

            let x = axes.a * pow(abs(cosT), inverseN) * sign(cosT)
            let y = axes.b * pow(abs(sinT), inverseN) * sign(sinT)
            
            let vertex = CGPoint(x: x, y: y)
            baseCurve.vertices += [vertex]
            
            // the orthogonal (== normal) to the curve at this point
            let dX = axes.b * inverseN * pow(abs(sinT), (inverseN - 1)) * cosT
            let dY = axes.a * inverseN * pow(abs(cosT), (inverseN - 1)) * sinT
            
            // store the normal in unit-vector form. thank you
            // 10th-grade geometry, euclid, and similar triangles
            let hypotenuse = hypot(dX, dY)
            let normal = CGVector(dx: dX/hypotenuse, dy: dY/hypotenuse)
            baseCurve.normals += [normal]
            
            if Model.DEBUG_PRINT_COORDS {
                debugPrint(i: i, theta: theta, vertex: vertex, normal: normal)
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
