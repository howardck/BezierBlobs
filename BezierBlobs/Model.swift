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
typealias Tuples = [(vertex: CGPoint, normal: CGVector)]

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
        
        zigZagCurves = calculateRandomlyPerturbedZigZagCurves(doZig: animateToZigPhase,
                                                              using: self.offsets)
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
        zigZagCurves = calculateZigZagCurves_2(using: self.offsets)
        blobCurve = tuples.map{ $0.vertex }
        
        // WHY BUG NO $0.vertex field ???
        // blobCurve = tuples.map{ $0.vertex }
    }
       
    //MARK:-
    
    var pageType: PageType?
    
    // the basis of everything else ...
    //MARK:- calculate the main baseCurve: vertices plus normals
    func calculateSuperEllipse(for numPoints: Int,
                               with axes: Axes) -> (baseCurve:(vertices:[CGPoint], normals: [CGVector]),
                                                    tuples: [(CGPoint, CGVector)])
    {
        // TO DO: look at trying ~ ([(vertex: CGPoint, normal: CGVector)]
        var baseCurve = (vertices: [CGPoint](), normals: [CGVector]())
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
            
            baseCurve.vertices += [vertex]
            
            // the orthogonal (== normal) to the curve at this point
            let dX = axes.b * inverseN * pow(abs(sinT), (inverseN - 1)) * cosT
            let dY = axes.a * inverseN * pow(abs(cosT), (inverseN - 1)) * sinT
            
            // store the normal in unit-vector form. thank you
            // 10th-grade geometry, euclid, and similar triangles
            let hypotenuse = hypot(dX, dY)
            let normal = CGVector(dx: dX/hypotenuse, dy: dY/hypotenuse)
            baseCurve.normals += [normal]
            
            // @@@@@@@@ NEW NEW NEW NEW NEW NEW NEW NEW NEW
            tuples += [(vertex: vertex, normal: normal)]
            // @@@@@@@@ NEW NEW NEW NEW NEW NEW NEW NEW NEW
            
            if Model.DEBUG_PRINT_COORDS {
                debugPrint(i: i, theta: theta, vertex: vertex, normal: normal)
                i += 1
            }
        }
        return (baseCurve: baseCurve, tuples: tuples)
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
        //offsets.inner = -80
        //offsets.outer = 100
        // DEBUG DEBUG @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        
        self.axes = axes
        if pageDescription.forceEqualAxes {
            let minab = min(axes.a, axes.b)
            self.axes = (a: minab, b: minab)
        }

        let baseCurveListPlusTuples = calculateSuperEllipse(for: self.numPoints,
                                                            with: self.axes)
        self.baseCurve = baseCurveListPlusTuples.baseCurve
        self.tuples = baseCurveListPlusTuples.tuples
        
        if Self.DEBUG_PRINT_BASIC_SE_PARAMS {
            print("Model.calculateSuperEllipseCurves(PageType.\(pageType.rawValue))")
            //print("-------------------------------------")
            print("  numPoints: {\(numPoints)} ")
            print("  axes: (a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))})")
            print("  offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
        }
        
        self.perturbationLimits = match(perturbLimits: self.perturbationLimits, to: offsets)
        
        boundingCurves = calculateBoundingCurves(using: self.offsets)
        normalsCurve = calculateNormalsPseudoCurve()
        zigZagCurves = calculateZigZagCurves_2(using: self.offsets)
        
        if ContentView.StatusTracker.isUninitialzed(pageType: pageType) {
            setInitialBlobCurve()
            ContentView.StatusTracker.markInited(pageType: pageType)
        }
        else {
            animateToCurrZigZagPhase()
        }
    }
    
    func match(perturbLimits: PerturbationLimits,
               to offsets: Offsets) -> PerturbationLimits
    {
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("Model.adjust(perturbationLimits)")
            print("offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            print("perturbationLimits BEFORE adjustment: " +
                    "\n   (inner: {\(perturbLimits.inner)},  " +
                    "outer: {\(perturbLimits.outer)} ) "
                  )
        }
        let pLimits = (inner: perturbLimits.inner * offsets.inner,
                       outer: perturbLimits.outer * offsets.outer)
        
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("perturbationLimits AFTER adjustment: \n   " +
                  "(inner: {\(pLimits.inner)}, outer: {\(pLimits.outer)} ) ")
        }
        return pLimits
    }
    
    //MARK: - Support Curves
    
    func random(maxPerturbation: CGFloat) -> CGFloat {//}, debugIsEven: Bool) -> CGFloat {
        
        let val = CGFloat.random(in: -abs(maxPerturbation)...abs(maxPerturbation))
//        print("random(maxPerturbation: {\(maxPerturbation)}, val: {\(rVal.format(fspec: "6.4"))} ")
        return val
    }

    func calculateRandomlyPerturbedZigZagCurves(doZig: Bool,
                                                using offsets: Offsets) -> ZigZagCurves {

        let zipped = zip(baseCurve.vertices, baseCurve.normals)

        let zigCurve = doZig ? randomlyPermuteZigCurve(vertexNormalTuples: zipped) : zigZagCurves.zig
        let zagCurve = !doZig ? randomlyPermuteZagCurve(vertexNormalTuples: zipped) : zigZagCurves.zag

        return (zigCurve, zagCurve)
    }
    
    func calculateRandomlyPerturbedZigZagCurves_2(using offsets: Offsets) -> ZigZagCurves {
        let z = tuples.enumerated()
        
        let zig = randomlyPermuteZigCurve_2(tuples: z, using: offsets)
        let zag = randomlyPermuteZigCurve_2(tuples: z, using: offsets)
        
        return (zig, zag)
    }
    
    func randomlyPermuteZigCurve_2(tuples: EnumeratedSequence<Array<(vertex: CGPoint, normal: CGVector)>>, using offsets: Offsets) -> [CGPoint] {
        tuples.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer + random(maxPerturbation: perturbationLimits.outer) :
                                offsets.inner + random(maxPerturbation: perturbationLimits.inner),
                            along: $0.1.1)
        }
    }

    func randomlyPermuteZagCurve_2(tuples: EnumeratedSequence<[(vertex: CGPoint, normal: CGVector)]>, using offsets: Offsets) -> [CGPoint] {
        tuples.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner + random(maxPerturbation: perturbationLimits.inner) :
                                offsets.outer + random(maxPerturbation: perturbationLimits.outer),
                            along: $0.1.1)
        }
    }
    
    func randomlyPermuteZigCurve(vertexNormalTuples: Zip2Sequence<[CGPoint], [CGVector]>) -> [CGPoint] {
        
        vertexNormalTuples.enumerated().map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer + random(maxPerturbation: perturbationLimits.outer) :
                                offsets.inner + random(maxPerturbation: perturbationLimits.inner),
                            along: $0.1.1)
        }
    }
    
    func randomlyPermuteZagCurve(vertexNormalTuples: Zip2Sequence<[CGPoint], [CGVector]>) -> [CGPoint] {
        
        return vertexNormalTuples.enumerated().map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner + random(maxPerturbation: perturbationLimits.inner) :
                                offsets.outer + random(maxPerturbation: perturbationLimits.outer),
                            along: $0.1.1)
        }
    }

//    func calculateZigZagCurves(using offsets: Offsets) -> ZigZagCurves {
//
//        let z = zip(baseCurve.vertices, baseCurve.normals).enumerated()
//        let zig = z.map {
//            $0.1.0.newPoint(at: $0.0.isEven() ? offsets.outer : offsets.inner,
//                            along: $0.1.1)
//        }
//        let zag = z.map {
//            $0.1.0.newPoint(at: $0.0.isEven() ?  offsets.inner : offsets.outer,
//                            along: $0.1.1)
//        }
//        return (zig, zag)
//    }
    
    // initial plain-jane unperturbed variety
    func calculateZigZagCurves_2(using offsets: Offsets) -> ZigZagCurves {

        let z = tuples.enumerated()
        let zig = z.map {
            $0.1.0.newPoint(at: $0.0.isEven() ? offsets.outer : offsets.inner,
                            along: $0.1.1)
        }
        let zag = z.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?  offsets.inner : offsets.outer,
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
