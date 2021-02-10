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
typealias ZigZagCurvesTest = (zigTest: [CGFloat], zagTest: CGFloat)

typealias BaseCurveType = (vertices: [CGPoint], normals: [CGVector])
typealias Tuples = [(vertex: CGPoint, normal: CGVector)]

typealias PerturbationLimits =  (inner: CGFloat, outer: CGFloat)

class Model: ObservableObject { // init() { print("Model.init()") }
    
    static let DEBUG_PRINT_BASIC_SE_PARAMS = false
    static let DEBUG_PRINT_VERTEX_NORMALS = false
    static let DEBUG_TRACK_ZIGZAG_PHASING = false
    static let DEBUG_PRINT_RANDOMIZED_OFFSET_CALCS = false
    static let DEBUG_ADJUST_PERTURBATION_LIMITS = true
    
    @Published var blobCurve = [CGPoint]()
    
    // at vertex 0:
    // zig configuration starts to the outside
    // zag configuration starts to the inside
    
    // go to the outside (== ZIG) first
    var animateToZigPhase = true
    
    static let VANISHINGLY_SMALL_DOUBLE = 0.000000000000000001  // kludge ahoy?
    
    var axes : Axes = (1, 1)
    
    enum ZigZagType {
        case zig
        case zag
    }
    
    // MARK:-
    //var baseCurve : BaseCurveType = (vertices: [CGPoint](), normals: [CGVector]())
    var tuples : Tuples = [(CGPoint, CGVector)]()
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
        
        let zigZagDeltas : ([CGFloat], [CGFloat]) = randomDeltasForZigZagPerturbations()
        zigZagCurves = calculateNewZigZags(deltas: zigZagDeltas)

        // CURRENT WAY OF DOING THINGS. BYZANTINE!
        //zigZagCurves = calculateRandomlyPerturbedZigZags(doZig: animateToZigPhase)
        
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
    
    //MARK:-
    func setInitialBlobCurve() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.setInitialBlobCurve(PageType.\(pageType!.rawValue))" )
        }
        blobCurve = tuples.map{ $0.vertex }
    }
    
    func returnToInitialConfiguration() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.returnToInitialConfiguration(PageType.\(pageType!.rawValue))" )
        }
        animateToZigPhase = true
        
        // recalculate with 0 perturbations
        zigZagCurves = calculateZigZagCurves()
        blobCurve = tuples.map{ $0.vertex }
    }
       
    //MARK:-
    
    var pageType: PageType?
    
    // the basis of everything else ...
    //MARK:- calculate the main baseCurve: vertices plus normals
    func calculateSuperEllipse(for numPoints: Int,
                               with axes: Axes) -> (//baseCurve:(vertices:[CGPoint], normals: [CGVector]),
                                                    [(CGPoint, CGVector)])
    {
        // TO DO: look at trying ~ ([(vertex: CGPoint, normal: CGVector)]
        //var baseCurve = (vertices: [CGPoint](), normals: [CGVector]())
        var tuples : Tuples = [(vertex: CGPoint, normal: CGVector)]()
        
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
            
           //baseCurve.vertices += [vertex]
            
            // the orthogonal (== normal) to the curve at this point
            let dX = axes.b * inverseN * pow(abs(sinT), (inverseN - 1)) * cosT
            let dY = axes.a * inverseN * pow(abs(cosT), (inverseN - 1)) * sinT
            
            // store the normal in unit-vector form. thank you
            // 10th-grade geometry, euclid, and similar triangles
            let hypotenuse = hypot(dX, dY)
            let normal = CGVector(dx: dX/hypotenuse, dy: dY/hypotenuse)
            //baseCurve.normals += [normal]
            
            // @@@@@@@@ NEW NEW NEW NEW NEW NEW NEW NEW NEW
            tuples += [(vertex: vertex, normal: normal)]
            // @@@@@@@@ NEW NEW NEW NEW NEW NEW NEW NEW NEW
            
            if Model.DEBUG_PRINT_VERTEX_NORMALS {
                debugPrint(i: i, theta: theta, vertex: vertex, normal: normal)
                i += 1
            }
        }
        return (tuples)
    }
    
    func sign(_ number: Double) -> Double {
         if number > 0 { return 1 }
         return number == 0 ? 0 : -1
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

        self.axes = axes
        if pageDescription.forceEqualAxes {
            let minab = min(axes.a, axes.b)
            self.axes = (a: minab, b: minab)
        }

        self.tuples = calculateSuperEllipse(for: self.numPoints,
                                            with: self.axes)
        //self.baseCurve = baseCurveListPlusTuples.baseCurve
        //self.tuples = baseCurveListPlusTuples
        
        if Self.DEBUG_PRINT_BASIC_SE_PARAMS {
            print("Model.calculateSuperEllipseCurves(PageType.\(pageType.rawValue))")
            //print("-------------------------------------")
            print("  numPoints: {\(numPoints)} ")
            print("  axes: (a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))})")
            print("  offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
        }
        
        self.perturbationLimits = upscale(perturbationLimits, toMatch: offsets)
        // --------------------------------------------------------------------
        boundingCurves = calculateBoundingCurves(using: self.offsets)
        normalsCurve = calculateNormalsPseudoCurve()
        zigZagCurves = calculateZigZagCurves()
        // --------------------------------------------------------------------

        if ContentView.StatusTracker.isUninitialzed(pageType: pageType) {
            setInitialBlobCurve()
            ContentView.StatusTracker.markInited(pageType: pageType)
        }
        else {
            animateToCurrZigZagPhase()
        }
    }
    
    func upscale(_: PerturbationLimits,
               toMatch offsets: Offsets) -> PerturbationLimits
    {
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("Model.upscale(perturbationLimits)")
            print("offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            
            print("perturbationLimits before upscaling : ( inner: {\(perturbationLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {\(perturbationLimits.outer.format(fspec: "4.2"))} ) "
                  )
        }
        let pLimits = (inner: abs(perturbationLimits.inner * offsets.inner),
                       outer: abs(perturbationLimits.outer * offsets.outer))
        
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("perturbationLimits after  upscaling : " +
                    "( inner: {+/- \(pLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {+/- \(pLimits.outer.format(fspec: "4.2"))} ) ")
        }
        return pLimits
    }
    
    //MARK: - Support Curves
    
    func randomPerturbation(within limits: CGFloat) -> CGFloat {
        
        return CGFloat.random(in: -abs(limits)...abs(limits))
    }
    
    func randomDeltasForZigZagPerturbations() -> (zigDeltas: [CGFloat], zagDeltas: [CGFloat])
    {
        let zigDeltas = tuples.enumerated().map {
            $0.0.isEven() ?
                randomPerturbation(within: perturbationLimits.outer) :
                randomPerturbation(within: perturbationLimits.inner)
        }
        let zagDeltas = tuples.enumerated().map {
            $0.0.isEven() ?
                randomPerturbation(within: perturbationLimits.inner) :
                randomPerturbation(within: perturbationLimits.outer)
        }
        
        return (zigDeltas: zigDeltas, zagDeltas: zagDeltas)
    }
    
    func calculateNewZigZags(deltas: (zig: [CGFloat], zag: [CGFloat])) -> ZigZagCurves {
        
        let enumerated = self.tuples.enumerated()
        let zig = enumerated.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer + deltas.zig[$0.0] :
                                offsets.inner + deltas.zig[$0.0],
                            along: $0.1.1)
        }
        let zag = enumerated.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner + deltas.zag[$0.0]:
                                offsets.outer + deltas.zag[$0.0],
                            along: $0.1.1)
        }
        return (zig, zag)
    }
    
    // ===========  BELOW: THE MORE COMPLICATED WAY I'VE BEEN DOING IT TO DATE  ===========
    
    // only zig or zag is changing, but still need to rebuild (zig, zag) using both
    func calculateRandomlyPerturbedZigZags(doZig: Bool) -> ZigZagCurves {
        let eTuples = tuples.enumerated()
        
        let zig = doZig ? randomlyPermutedZigCurve(eTuples: eTuples) : zigZagCurves.zig
        let zag = !doZig ? randomlyPermutedZagCurve(eTuples: eTuples) : zigZagCurves.zag

        return (zig, zag)
    }
    
    func randomlyPermutedZigCurve(eTuples: EnumeratedSequence<[(vertex: CGPoint, normal: CGVector)]>) -> [CGPoint] {
        
        eTuples.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer + randomPerturbation(within: perturbationLimits.outer) :
                                offsets.inner + randomPerturbation(within: perturbationLimits.inner),
                            along: $0.1.1)
        }
    }

    func randomlyPermutedZagCurve(eTuples: EnumeratedSequence<[(vertex: CGPoint, normal: CGVector)]>) -> [CGPoint] {

        eTuples.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner + randomPerturbation(within: perturbationLimits.inner) :
                                offsets.outer + randomPerturbation(within: perturbationLimits.outer),
                            along: $0.1.1)
        }
    }

    // initial plain-jane unperturbed variety
    func calculateZigZagCurves() -> ZigZagCurves {

        let z = tuples.enumerated()
        let zig = z.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer :
                                offsets.inner,
                            along: $0.1.1)
        }
        let zag = z.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner :
                                offsets.outer,
                            along: $0.1.1)
        }
        return (zig, zag)
    }
    
    func calculateBoundingCurves(using offsets: Offsets) -> BoundingCurves {
        
         (inner: tuples.map{ $0.newPoint(at: offsets.inner, along: $1)},
          outer: tuples.map{ $0.newPoint(at: offsets.outer, along: $1)})
    }
    
    func calculateNormalsPseudoCurve() -> [CGPoint] {
        var normals = [CGPoint]()
        for i in 0..<numPoints {
            normals.append(boundingCurves.inner[i])
            normals.append(boundingCurves.outer[i])
        }
        return normals
    }
}
