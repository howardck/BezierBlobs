//
//  Model.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

typealias Axes = (a: Double, b: Double)
typealias BaseCurveTuples = [(vertex: CGPoint, normal: CGVector)]
typealias OffsetCurves = (inner: [CGPoint], outer: [CGPoint])
typealias ZigZagCurves = (zig: [CGPoint], zag: [CGPoint])

typealias Offsets = (inner: CGFloat, outer: CGFloat)
 
// the first form, given as relative percentages of the semiMinorAxis,
// gets converted to the second form, in absolute screen distances
typealias AxisRelativePerturbationDeltas = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)

// the innerRange is centred more or less on the inner curve, the outerRange on the outer
typealias PerturbationDeltas = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)

enum BlobPhase : String {
    case zig
    case zag
    
    mutating func nextPhase() {
        switch self {
            case .zig : self = .zag
            case .zag : self = .zig
        }
    }
}

class Model: ObservableObject {

    // it'd be nicer to say nilDelta == 0..<0 but that's a crasher
    static let NIL_DELTAS : Range<CGFloat> = 0..<CGFloat(SEParametrics.VANISHINGLY_SMALL_DOUBLE)
//    static let NIL_DELTAS : Range<CGFloat> = 0..<CGFloat(0)
    
    var pageType : PageDescriptors.PageType!
    
    var offsets : Offsets = (inner: 0, outer: 0)
    var perturbationDeltas : PerturbationDeltas = (innerRange: 0..<0,
                                                   outerRange: 0..<0)
    //MARK:-
    init() {
        // print("\nModel.init()")
    }
    
    //MARK:-
    // animated curves: temporarily constructed by the graphics subsystem
    // to in-between between two curves explicitly delineated by the user
    
    @Published var blobCurve = [CGPoint]()
    @Published var orbitalCurves = (inner: [CGPoint](), outer: [CGPoint]())
    //[(inner: CGPoint, outer: CGPoint)]()
         
    // zig vs zag curve configurations:
    // zig : defined by curve in which vertex[0] marker initially moves to the outside
    // zag : the vertex[0] marker initially moves to the inside
    
    //var nextPhaseIsZig = true
    
    var blobPhase : BlobPhase = .zig
    
      // MARK:-

    // our supporting cast, all static
    var baseCurve = [(vertex: CGPoint, normal: CGVector)]()
    var offsetCurves : OffsetCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var normalsCurve : [CGPoint] = [CGPoint]()
    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]() )
    var axes : Axes = (1.0, 1.0)
    
    // MARK: - a new curve at distance 'offset' from the basecurve
    
    func curve(at offset: Double) -> [CGPoint] {
        baseCurve.map{ $0.newPoint(at: offset, along: $1)}
    }
        
    //MARK: - SUPERELLIPSE
    func calculateSuperEllipse(order: Double,
                               numPoints: Int,
                               axes: Axes) {
        baseCurve = SEParametrics.calculateSuperEllipse(ε: 2.0/order,
                                                        for: numPoints,
                                                        with: axes)
    }
    
    //MARK: -
    func calculateOffsetsAndNormalsSupportCurves() {
        
        offsetCurves = calculateOffsetCurves(using: offsets)
        normalsCurve = calculateNormals()
        
        setInitialAnimatingCurves()
    }
    
    func calculateOffsetCurves(using offsets: Offsets) -> OffsetCurves {
        (inner: curve(at: offsets.inner),
         outer: curve(at: offsets.outer))
    }
    
//    func calculateOffsetCurves(using offsets: Offsets) -> OffsetCurves {
//        (inner: baseCurve.map{ $0.newPoint(at: offsets.inner, along: $1)},
//         outer: baseCurve.map{ $0.newPoint(at: offsets.outer, along: $1)})
//    }
    
    func calculateNormals() -> [CGPoint] {
        var normals = [CGPoint]()
        for i in 0..<baseCurve.count {
            normals.append(offsetCurves.inner[i])
            normals.append(offsetCurves.outer[i])
        }
        return normals
    }
    
    //MARK: - MISC FUNCTIONALITY
    func evenNumberedVertices(for curve: [CGPoint]) -> Set<Int>
    {
        Set((0..<curve.count).map{ $0 }.filter{ $0 % 2 == 0 })
    }
    
    func calculatePerturbationDeltas(descriptors: PageDescriptors, minAxis: CGFloat) {
        let relInRange = descriptors.axisRelDeltas.innerRange
        let relOutRange = descriptors.axisRelDeltas.outerRange
        
        let innerRange = (relInRange.lowerBound * minAxis)..<(relInRange.upperBound * minAxis)
        let outerRange = (relOutRange.lowerBound * minAxis)..<(relOutRange.upperBound * minAxis)

        perturbationDeltas = (innerRange: innerRange,
                              outerRange: outerRange)
    }

    
    //MARK: - CALLS TO ANIMATE
    
    func animateToNextOrbitalMarkersConfiguration() {
        
        // move all inner & outer offset markers 1 vertex clockwise
        
        orbitalCurves.outer.append(orbitalCurves.outer.removeFirst())
        
        // do this if you want the inner one to move clockwise as well
        // orbitalCurves.inner.append(orbitalCurves.inner.removeFirst())

        orbitalCurves.inner.insert(orbitalCurves.inner.removeLast(), at: 0)
    }
    
    // Not Currently Implemented. this approach requires a larger value
    // of numPoints and/or greater radial movement to look good,
    // which in turn would require some architectural changes.
    
    func animateToRandomOffsetWithinExtendedEnvelope() {
        let innerLimit = offsets.inner + perturbationDeltas.innerRange.lowerBound
        let outerLimit = offsets.outer + perturbationDeltas.outerRange.upperBound
        
        blobCurve = baseCurve.map {
            let randomOffset = CGFloat.random(in: -abs(innerLimit)...abs(outerLimit))
            return $0.newPoint(at: randomOffset, along: $1)
        }
    }

    func animateToNextFixedPerturbationDelta() {
        
        var originMovingToOutside = blobPhase == .zig
        var curve = [CGPoint]()
        
        for vertexTuple in baseCurve {
            
        // adding perturbation delta limits here makes for a more dramatic
        // animation (ie larger swings in amplitude). uncomment the optional
        // addends below to see this. NOTE: this might cause "arm crossover"
        // effects not otherwise seen.
            
            let offset : CGFloat = originMovingToOutside ?
                offsets.outer : //+ perturbationDeltas.outerRange.upperBound :
                offsets.inner //+ perturbationDeltas.innerRange.lowerBound
            
            originMovingToOutside.toggle()
            curve += [vertexTuple.vertex.newPoint(at: offset,
                                                  along: vertexTuple.normal)]
        }
        blobCurve = curve // cause a state change to drive the animation
    }
    
    func animateToNextRandomizedPerturbationDelta() {
        var curve = [CGPoint]()
        var originMovingToOutside = blobPhase == .zig
        
        for vertexTuple in baseCurve {
            
            let offset = originMovingToOutside ?
                offsets.outer + CGFloat.random(in: perturbationDeltas.outerRange) :
                offsets.inner + CGFloat.random(in: perturbationDeltas.innerRange)
            
            originMovingToOutside.toggle()
            curve += [vertexTuple.vertex.newPoint(at: offset,
                                                  along: vertexTuple.normal)]
        }
        blobCurve = curve
    }

    //MARK: - INITIAL CONFIGURATION
    func setInitialBlobCurveToRandomizedZig() {
        
        animateToNextRandomizedPerturbationDelta()
    }
    
    func setInitialAnimatingCurves() {
        
        blobCurve = baseCurve.map{ $0.vertex }
        
        //orbitalCurves.inner = blobCurve
        //orbitalCurves.outer = blobCurve
        // we could orbit along a different curve if we wanted
        
        orbitalCurves.outer = offsetCurves.outer
        orbitalCurves.inner = offsetCurves.inner
    }
        
    func returnToInitialConfiguration() {

        setInitialAnimatingCurves()
        blobPhase = .zig
    }
    
    //MARK: - ZIG-ZAGS (not currently used)
    
    // other ways of doing it; not currently used
    func calculateZigZags() -> ZigZagCurves {
        (zig: calculateZigCurve(), zag: calculateZagCurve())
    }
    
    func calculateZigCurve() -> [CGPoint] {
        baseCurve.enumerated().map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer  :
                                offsets.inner,
                            along: $0.1.1)
        }
    }
    
    func calculateZagCurve() -> [CGPoint] {
        baseCurve.enumerated().map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner :
                                offsets.outer ,
                            along: $0.1.1)
        }
    }
}
