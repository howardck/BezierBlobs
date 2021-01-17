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
typealias PerturbationLimits =  (
                                    inner: (inward: CGFloat, outward: CGFloat),
                                    outer: (inward: CGFloat, outward: CGFloat)
                                )
class Model: ObservableObject { // init() { print("Model.init()") }
    
    static let DEBUG_PRINT_COORDS = false
    static let DEBUG_TRACK_ZIGZAG_PHASING = false
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
    var perturbationLimits : PerturbationLimits = (inner: (inward: 0, outward: 0),
                                                   outer: (inward: 0, outward: 0))
    
    //MARK: - ANIMATE TO ZIG-ZAGS
    func animateToNextZigZagPhase() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.animateToNextZigZagPhase():: animateToZig == {\(animateToZigPhase)}")
        }
        
        blobCurve = animateToZigPhase ?
            perturbRandomly(zigZagType: .zig) :
            perturbRandomly(zigZagType: .zag)
        
        animateToZigPhase.toggle()
    }
    
    func animateToCurrZigZagPhase() {
        blobCurve = animateToZigPhase ?
            zigZagCurves.zag :
            zigZagCurves.zig
    }
    
    //MARK:-
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
    
    //MARK:- PERTURB ZIG-ZAG CURVE W/IN PERTURBATION LIMITS

    func perturbRandomly(zigZagType: ZigZagType) -> [CGPoint]
    {
        // (1) build a list of semi-random deltas for each vertex, built
        //     against maximum inward and outward limits for pts on the
        //     inner boundary and separately for pts on the outer one
        // (2) iterate along each zig-zag, applying the delta at each point to produce a
        //      a new point inwardly or outwardly from the original along its normal
        //      that becomes part of the new 'randomized' zig-zag
        
        let curve = zigZagType == .zig ? zigZagCurves.zig : zigZagCurves.zag
        
        let deltas = generatePerturbationDeltas(for: zigZagType,
                                                using: self.perturbationLimits.inner)
        return applyList(of: deltas, to: curve)
    }
    
    func generatePerturbationDeltas(for zigZagType: ZigZagType,
                                    using deltaLimits: (inward: CGFloat, outward: CGFloat)) -> [CGFloat]
    {
        let perturbationDeltas = Array<CGFloat>(repeating: 0,
                                                count: self.numPoints).map { _ in
            CGFloat.random(in: deltaLimits.inward...deltaLimits.outward)
        }
        
        if Self.DEBUG_PRINT_RANDOMIZED_OFFSET_CALCS {
            print("\ngeneratePerturbationDeltas() ................")

            print("envelope offsets: { (inner: \(offsets.inner), outer: \(offsets.outer)) }")
            print("maxPerturbationDeltas: { (inward: \(deltaLimits.inward), outward: \(deltaLimits.outward) }")
            print("randomized perturbation deltas:" )
        }
        return perturbationDeltas
    }
    
    func applyList(of perturbationDeltas: [CGFloat], to zzCurve: [CGPoint]) -> [CGPoint] {
        
        if Self.DEBUG_PRINT_RANDOMIZED_OFFSET_CALCS {
            _ = perturbationDeltas.enumerated().map {
                print("delta \([$0]): {\(($1).format(fspec: "7.4"))}")
            }
        }

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
        
        self.perturbationLimits = establish(perturbationLimits: self.perturbationLimits, for: offsets)
        
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
    
    func establish(perturbationLimits: PerturbationLimits,
                   for offsets: Offsets) -> PerturbationLimits
    {
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("Model.adjust(perturbationLimits)")
            print("offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            print("perturbationLimits BEFORE adjustment: " +
                "\n   inner.inward: {\(perturbationLimits.inner.inward)} " +
                "inner.outward: {\(perturbationLimits.inner.outward)} " +
                "\n   outer.inward: {\(perturbationLimits.outer.inward)} " +
                "outer.outward: {\(perturbationLimits.outer.inward)} "
            )
        }
        var perturbLimits : PerturbationLimits
//        perturbLimits.inner = (inward: offsets.inner + (perturbationLimits.inner.inward * offsets.inner),
//                               outward: offsets.inner - (perturbationLimits.inner.outward * offsets.inner))
//        perturbLimits.outer = (inward: perturbationLimits.outer.inward * offsets.outer,
//                               outward: perturbationLimits.outer.outward * offsets.outer)
        
//        perturbLimits.inner = (inward: (perturbationLimits.inner.inward * offsets.inner),
//                               outward: (perturbationLimits.inner.outward * offsets.inner))
//        perturbLimits.outer = (inward: perturbationLimits.outer.inward * offsets.outer,
//                               outward: perturbationLimits.outer.outward * offsets.outer)
//
        perturbLimits.inner = (inward: -abs(perturbationLimits.inner.inward * offsets.inner),
                               outward: abs(perturbationLimits.inner.outward * offsets.inner))
        perturbLimits.outer = (inward: 0,
                               outward: 0)
        
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("perturbationLimits AFTER adjustment: " +
                    "\n   inner.inward: {\(perturbLimits.inner.inward)} " +
                    "inner.outward: {\(perturbLimits.inner.outward)} " +
                    "\n   outer.inward: {\(perturbLimits.outer.inward)} " +
                    "outer.outward: {\(perturbLimits.outer.inward)} "
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
         on enumerating a zipped array pair of vertices & their normals,
         a map{} function sees this:
         
            {$0.0}: index of the point; {$0.1}: the vertex/normal pair for the point. ie
                                        {$0.1.0}: the vertex
                                        {@0.1.1}: the normal (a CGVector) at the point
         */
        // .zig curve starts to the outside at vertex 0 (red in the current styling)
        let zigCurve = zipped.map {
            $0.1.0.newPoint(at: $0.0.isEven() ? offsets.outer : offsets.inner,
                            along: $0.1.1)
        }
        // .zag does just the opposite (yellow ditto ...)
        let zagCurve = zipped.map {
            $0.1.0.newPoint(at: $0.0.isEven() ? offsets.inner : offsets.outer,
                            along: $0.1.1)
        }
        return (zigCurve, zagCurve)
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
