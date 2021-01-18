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

typealias PerturbationLimits =  (inner: CGFloat, outer: CGFloat)

class Model: ObservableObject { // init() { print("Model.init()") }
    
    static let DEBUG_PRINT_COORDS = false
    static let DEBUG_TRACK_ZIGZAG_PHASING = true
    static let DEBUG_PRINT_BASIC_SE_PARAMS = true
    static let DEBUG_PRINT_RANDOMIZED_OFFSET_CALCS = true
    static let DEBUG_ADJUST_PERTURBATION_LIMITS = true
    
    @Published var blobCurve = [CGPoint]()
    
    // at vertex 0:
    // zig configuration starts to the outside
    // zag configuration starts to the inside
    
    // go to the outside (== ZIG) first
    var animateToZigPhase = true
    
    static let VANISHINGLY_SMALL_DOUBLE = 0.000000000000000001  // kludge ahoy?
    
    var axes : Axes = (1, 1)

    // MARK:-
    // TODO: SEE NOTE in baseCurvePlusNormals() on possibly recasting as:
    // TODO: var baseCurve: ([(vertex: CGPoint, normal: CGVector)]
    
    enum ZigZagType {
        case zig
        case zag
    }
    
    // MARK:-
    var baseCurve : BaseCurveType = (vertices: [CGPoint](), normals: [CGVector]())
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]())
    var normalsCurve : [CGPoint] = [CGPoint]()
    
    //MARK:-
    //TODO: TODO: OFFSETS SHOULD BE A PLATFORM-SPECIFIC SCREEN RATIO
    
    var n: Double = 0.0
    var numPoints: Int = 0
    var offsets : Offsets = (inner: 0, outer: 0)
    
    var perturbationLimits : PerturbationLimits = (inner: 0, outer: 0)
    
    //MARK: - ANIMATE TO ZIG-ZAGS
    func animateToNextZigZagPhase() {
        
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.animateToNextZigZagPhase():: animateToZig == {\(animateToZigPhase)}")
        }
        zigZagCurves = calculateZigZagCurves(using: self.offsets)
        
        blobCurve = animateToZigPhase ?
            zigZagCurves.zig :
            zigZagCurves.zag
        
        animateToZigPhase.toggle()
    }
    
    func animateToCurrZigZagPhase() {
        blobCurve = animateToZigPhase ?
            zigZagCurves.zag :
            zigZagCurves.zig
    }
    
    func returnToInitialConfiguration() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.returnToInitialConfiguration(PageType.\(pageType!.rawValue))" )
        }
        animateToZigPhase = true
        
        // recalculate these with 0 perturbations
        zigZagCurves = calculateZigZagCurves(using: self.offsets,
                                             with: (inner: 0, outer: 0))
        blobCurve = baseCurve.vertices
    }
    
    //MARK:-
    func setInitialBlobCurve() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.setInitialBlobCurve(PageType.\(pageType!.rawValue))" )
        }
        
        blobCurve = baseCurve.vertices
    }
    
    func applyList(of perturbationDeltas: [CGFloat], to zzCurve: [CGPoint]) -> [CGPoint] {

        // ANOTHER WAY OF GENERATING A NEW ZIG-ZAG CURVE, BY AMENDING THE ORIGINAL ONE
        // (THO NOT QUITE RIGHT ...)
        
        // create a new zigZag by iterating along the current .zig or .zag curve and moving
        // in or out along the normal at each pt the disance perturbationDeltas[ix].
        
        let perturbedZigZag = zzCurve.enumerated().map {
            $0.1.newPoint(at: perturbationDeltas[ $0.0 ], along: baseCurve.normals[ $0.0 ])
        }
        
        return perturbedZigZag
    }
       
    //MARK:-
    
    var pageType: PageType?
    
    // the basis of everything else ...
    //MARK:- calculate the main baseCurve: vertices plus normals
    func calculateSuperEllipse(for numPoints: Int,
                               with axes: Axes) -> (vertices:[CGPoint],
                                                    normals: [CGVector])
    {
        // TO DO: look at trying ~ ([(vertex: CGPoint, normal: CGVector)]
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
        
//        alternatively:
//        let i_s = "\((i).format(fspec: "2"))"
//        let theta_s = "\((theta).format(fspec: "5.3"))"
//        let x_s = "\((vertex.x).format(fspec:" 7.2"))"
//        let y_s = "\((vertex.y).format(fspec: "7.2"))"
//        let dx_s = "\((normal.dx).format(fspec: "5.3"))"
//        let dy_s = "\((normal.dy).format(fspec: "5.3"))"
//        print( "[\(i_s)] theta: {\(theta_s)} | {x: \(x_s), y: \(y_s)} | {dx: \(dx_s), dy: \(dy_s)}" )
    }

    //MARK:-
    func calculateSuperEllipseCurves(for pageType: PageType,
                                     pageDescription: PageDescription,
                                     axes: Axes) {
        
        self.pageType = pageType
        self.perturbationLimits = pageDescription.perturbLimits
        
//        print("Model.calculateSuperEllipseCurves(): axes {a: \(axes.a), b: \(axes.b)}  {PageType.\(pageType.rawValue)}")
        
        self.numPoints = pageDescription.numPoints
        self.n = pageDescription.n
        
        // NOT SURE IF THIS IS THE BEST APPROACH HERE ...
        let radius = CGFloat((axes.a + axes.b)/2.0)
        
        // NOTA: offsets here are CGFloats based on pageDescription
        // offsets, which are percentages of the screen height & width
        
        offsets = (inner: radius * pageDescription.offsets.in,
                   outer: radius * pageDescription.offsets.out)
        
        // DEBUG DEBUG @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        offsets.inner = -80
        offsets.outer = 100
        // DEBUG DEBUG @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        
        self.axes = axes
        if pageDescription.forceEqualAxes {
            let minab = min(axes.a, axes.b)
            self.axes = (a: minab, b: minab)
        }

        self.baseCurve = calculateSuperEllipse(for: self.numPoints,
                                               with: self.axes)
        
        if Self.DEBUG_PRINT_BASIC_SE_PARAMS {
            print("Model.calculateSuperEllipseCurves(PageType.\(pageType.rawValue))")
            //print("-------------------------------------")
            print("  numPoints: {\(numPoints)} ")
            print("  axes: (a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))})")
            print("  offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
        }
        
        self.perturbationLimits = match(perturbationLimits: self.perturbationLimits, to: offsets)
        
        boundingCurves = calculateBoundingCurves(using: self.offsets)
        normalsCurve = calculateNormalsPseudoCurve()
        zigZagCurves = calculateZigZagCurves(using: self.offsets,
                                             with: (inner: 0, outer: 0))
        
        if ContentView.StatusTracker.isUninitialzed(pageType: pageType) {
            setInitialBlobCurve()
            ContentView.StatusTracker.markInited(pageType: pageType)
        }
        else {
            animateToCurrZigZagPhase()
        }
    }
    
    func match(perturbationLimits: PerturbationLimits,
               to offsets: Offsets) -> PerturbationLimits
    {
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("Model.adjust(perturbationLimits)")
            print("offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            print("perturbationLimits BEFORE adjustment: " +
                    "\n   (inner: {\(perturbationLimits.inner)},  " +
                    "outer: {\(perturbationLimits.outer)} ) "
                  )
        }
        var perturbLimits : PerturbationLimits

        perturbLimits = (inner: perturbationLimits.inner * offsets.inner,
                         outer: perturbationLimits.outer * offsets.outer)
        
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("perturbationLimits AFTER adjustment: " +
                    "\n   (inner: {\(perturbLimits.inner)},  " +
                    "outer: {\(perturbLimits.outer)} ) "
                  )
        }
        return perturbLimits
    }
    
    //MARK: - Support Curves

    // these define the two path extremes our generated blob path animates between.
    
    func calculateZigZagCurves(using offsets: Offsets) -> ZigZagCurves {

        // TO-DO: EXPLORE USING ARRAY OF TUPLES FOR baseCurve

        /*  instead of baseCurve being defined as ([CGPoint], [CGVector]),
            it could easily be instantiated as [(CGPoint, CGVector)].
            this has several advantages:
            (1) they're in zipped form from the start; we don't need to zip here.
            (2) they're already in array form so we don't need to do enumerated()
                to get an index
        */
        
        let zipped = zip(baseCurve.vertices, baseCurve.normals).enumerated()
        /*
            type(zipped) == [(vertex, normal)]. map sees:
            {$0.0}: index of the point
            {$0.1}: the vertex/normal pair for the point, ie
                    {$0.1.0}: the vertex
                    {@0.1.1}: the normal (a CGVector) at the point
         */
        // .zig curve starts to the outside at vertex 0 (red in the current styling)
        let zigCurve = zipped.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer + CGFloat.random(in: -perturbationLimits.outer...perturbationLimits.outer) :
                                offsets.inner + CGFloat.random(in: -abs(perturbationLimits.inner)...perturbationLimits.inner),
                            along: $0.1.1)
        }
        // .zag does the opposite (yellow styling ...)
        let zagCurve = zipped.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner + CGFloat.random(in: -abs(perturbationLimits.inner)...perturbationLimits.inner) :
                                offsets.outer + CGFloat.random(in: -perturbationLimits.outer...perturbationLimits.outer),
                            along: $0.1.1)
        }
        return (zigCurve, zagCurve)
    }
    
    func calculateZigZagCurves(using offsets: Offsets, with perturbRanges: PerturbationLimits) -> ZigZagCurves {

        let z = zip(baseCurve.vertices, baseCurve.normals).enumerated()

        let zig = z.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer + CGFloat.random(in: -perturbRanges.outer...perturbRanges.outer) :
                                offsets.inner + CGFloat.random(in: -abs(perturbRanges.inner)...perturbRanges.inner),
                            along: $0.1.1)
        }
 
        let zag = z.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner + CGFloat.random(in: -abs(perturbRanges.inner)...perturbRanges.inner) :
                                offsets.outer + CGFloat.random(in: -perturbRanges.outer...perturbRanges.outer),
                            along: $0.1.1)
        }
        return (zig: zig, zag: zag)
    }
    
    // define an envelope w/in which our blob blobs
    
    func calculateBoundingCurves(using offsets: Offsets) -> BoundingCurves {
        let z = zip(baseCurve.vertices, baseCurve.normals)
        return (inner: z.map{ $0.0.newPoint(at: offsets.inner, along: $0.1) },
                outer: z.map{ $0.0.newPoint(at: offsets.outer, along: $0.1) })
    }
    
    func calculateNormalsPseudoCurve() -> [CGPoint] {
        var normals = [CGPoint]()
        for i in 0..<boundingCurves.inner.count {
            normals.append(boundingCurves.inner[i])
            normals.append(boundingCurves.outer[i])
        }
        return normals
    }
}
