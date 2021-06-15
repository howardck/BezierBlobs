//
//  Model.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

typealias Axes = (a: Double, b: Double)
//typealias Offsets = (inner: CGFloat, outer: CGFloat)

typealias BaseCurvePairs = [(vertex: CGPoint, normal: CGVector)]
typealias BoundingCurves = (inner: [CGPoint], outer: [CGPoint])

typealias Offsets = (inner: CGFloat, outer: CGFloat)
 
// the first form, given as relative percentages of the semiMinorAxis,
// gets converted to the second form, as absolute screen distances
typealias AxisRelativePerturbationDeltas = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)

// the innerRange is centred (more or less) on the inner curve; the outerRange on the outer
typealias PerturbationDeltas = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)
/*
    Nomenclature is a bitch. at times I've referred to:
 
        o perturbation ranges
        o perturbation deltas
        o perturbation bands
        o perturbation limits
        o perturbation band curves
 
    and various combinations of the same. yikes! :-)
 */

class Model: ObservableObject {
    
    // it's be easier to say a nilDelta == 0..<0, but that's a crasher
    static let NIL_DELTAS : Range<CGFloat> = 0..<CGFloat(SEParametrics.VANISHINGLY_SMALL_DOUBLE)
    
    var offsets : Offsets = (inner: 0, outer: 0)
    var perturbationDeltas : PerturbationDeltas = (innerRange: 0..<0,
                                                   outerRange: 0..<0)
    
    //MARK:-
    init() {
        // print("\nModel.init()")
    }
    
    //MARK:-
    
    static let DEBUG_OVERLAY_SECOND_COPY_OF_NORMALS_PLUS_MARKERS = false
    static let DEBUG_SHOW_EXPERIMENTAL_INNER_AND_OUTER_PERTURBATION_BANDS = false
    static let DEBUG_PRINT_PAGEVIEW_INIT_BASIC_AXIS_PARAMS = false
    static let DEBUG_PRINT_BASIC_SE_PARAMS = false
    static let DEBUG_PRINT_VERTEX_NORMALS = false
    static let DEBUG_TRACK_ZIGZAG_PHASING = false
    static let DEBUG_PRINT_RANDOMIZED_OFFSET_CALCS = true
    static let DEBUG_ADJUST_PERTURBATION_LIMITS = true
    
    
    //MARK:-
    
    @Published var blobCurve = [CGPoint]()
         
    // zig vs zag configurations:
    // zig : vertex[0] marker moves to the outside
    // zag : vertex[0] marker moves to the inside
    
    var nextPhaseIsZig = true
  
    // MARK:-

    // our supporting cast
    var baseCurve : BaseCurvePairs = [(CGPoint, CGVector)]()
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var normalsCurve : [CGPoint] = [CGPoint]()
    var axes : Axes = (1.0, 1.0)
    

    var pageType: PageType?
    
    func calculatePerturbationDeltas(descriptors: PageDescription, minAxis: CGFloat) {
        let relInRange = descriptors.axisRelDeltas.innerRange
        let relOutRange = descriptors.axisRelDeltas.outerRange
        
        let innerRange = (relInRange.lowerBound * minAxis)..<(relInRange.upperBound * minAxis)
        let outerRange = (relOutRange.lowerBound * minAxis)..<(relOutRange.upperBound * minAxis)

        perturbationDeltas = (innerRange: innerRange,
                              outerRange: outerRange)
        
        print("   model.offsets : " +
                "(inner: [\(offsets.inner.format(fspec: "4.2"))] <—-|-—> " +
                "outer: [\(offsets.outer.format(fspec: "4.2"))]) ")
        
        print("   perturbationRanges: inner: (\(innerRange.lowerBound)..< \(innerRange.upperBound)) <—-|-—> " +
              "outer: (\(outerRange.lowerBound)..< \(outerRange.upperBound))")
    }

    //MARK:- MAIN SUPERELLIPSE
    func calculateSuperEllipse(for pageType: PageType,
                               n: Double,
                               numPoints: Int,
                               axes: Axes) {
        self.pageType = pageType
        
        baseCurve = SEParametrics.calculateSuperEllipse(for: numPoints,
                                                        n: n,
                                                        with: axes)
    }
    
    //MARK:- SUPPORT CURVES
    func calculateSupportCurves() {
        
        boundingCurves = calculateBoundingCurves(using: offsets)
        normalsCurve = calculateNormals()
        
        fixedInnerPerturbationBandCurves = EXPERIMENTAL_calculateFixedPerturbationBandsInner()
        fixedOuterPerturbationBandCurves = EXPERIMENTAL_calculateFixedPerturbationBandsOuter()
        
        setInitialBlobCurve()
    }
    
    typealias PerturbationBandCurves = (outer_inside: [CGPoint], outer_outside: [CGPoint])
    
    var fixedInnerPerturbationBandCurves = ( inner_inside: [CGPoint](), inner_outside: [CGPoint]() )
    var fixedOuterPerturbationBandCurves = ( outer_inside: [CGPoint](), outer_outside: [CGPoint]() )
    
    func EXPERIMENTAL_calculateFixedPerturbationBandsInner() -> ( inner_inside: [CGPoint], inner_outside: [CGPoint] )
    {
        let insideBound = perturbationDeltas.innerRange.lowerBound
        let outsideBound = perturbationDeltas.innerRange.upperBound
        
        return (inner_inside: baseCurve.map{ $0.newPoint(at: offsets.inner + insideBound, along: $1)},
         inner_outside: baseCurve.map{ $0.newPoint(at: offsets.inner + outsideBound, along: $1)})
    }
    
    func EXPERIMENTAL_calculateFixedPerturbationBandsOuter() -> PerturbationBandCurves
    {
        let insideBound = perturbationDeltas.outerRange.lowerBound
        let outsideBound = perturbationDeltas.outerRange.upperBound
        return
            (outer_inside: baseCurve.map{ $0.newPoint(at: offsets.outer + insideBound, along: $1) },
             outer_outside: baseCurve.map{ $0.newPoint(at: offsets.outer + outsideBound, along: $1) })
    }
    
    //MARK:- MISC FUNCTIONALITY
    func evenNumberedVertices(for curve: [CGPoint]) -> Set<Int>
    {
        let evens = (0..<curve.count).map{ $0 }.filter{ $0 % 2 == 0 }
        return Set(evens)
    }
    
    // not currently implemented. looks interesting but requires a much larger
    // value of numPoints to look good, which in turn requires some architectural changes.
    
    func animateToRandomOffsetWithinExtendedEnvelope() {
        let innerLimit = offsets.inner + perturbationDeltas.innerRange.lowerBound
        let outerLimit = offsets.outer + perturbationDeltas.outerRange.upperBound
        
        blobCurve = baseCurve.map {
            let randomOffset = CGFloat.random(in: -abs(innerLimit)...abs(outerLimit))
            return $0.newPoint(at: randomOffset, along: $1)
        }
    }

    //MARK:- CALLS TO ANIMATE
    func animateToNextFixedPerturbationDelta() {
        
        var movingToOutside = self.nextPhaseIsZig
        var curve = [CGPoint]()
        
        for vertexTuple in baseCurve {
            
            let offset : CGFloat = movingToOutside ?
                offsets.outer + perturbationDeltas.outerRange.upperBound :
                offsets.inner + perturbationDeltas.innerRange.upperBound
            
            movingToOutside.toggle()
            curve += [vertexTuple.vertex.newPoint(at: offset,
                                                 along: vertexTuple.normal)]
        }
        blobCurve = curve // we update blobCurve; this drives the animation
        self.nextPhaseIsZig.toggle()
    }
    
    func animateToNextRandomizedPerturbationDelta() {
        var curve = [CGPoint]()
        var movingToOutside = self.nextPhaseIsZig
        
        for vertexTuple in baseCurve {
            
            let offset = movingToOutside ?
                offsets.outer + CGFloat.random(in: perturbationDeltas.outerRange) :
                offsets.inner + CGFloat.random(in: perturbationDeltas.innerRange)
            
            movingToOutside.toggle()
            curve += [vertexTuple.vertex.newPoint(at: offset,
                                                  along: vertexTuple.normal)]
        }
        blobCurve = curve
        self.nextPhaseIsZig.toggle()
    }
    
    //MARK:-
    func setInitialBlobCurve() {
        
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.setInitialBlobCurve(PageType.\(pageType!.rawValue))" )
        }
        blobCurve = baseCurve.map{ $0.vertex }
        nextPhaseIsZig = true
    }
    
    func returnToInitialConfiguration() {

        setInitialBlobCurve()
    }
    
    // MARK:- OTHER CURVES
    
    func calculateBoundingCurves(using offsets: Offsets) -> BoundingCurves {
        (inner: baseCurve.map{ $0.newPoint(at: offsets.inner, along: $1)},
         outer: baseCurve.map{ $0.newPoint(at: offsets.outer, along: $1)})
    }
    
    func calculateNormals() -> [CGPoint] {
        var normals = [CGPoint]()
        for i in 0..<baseCurve.count {
            normals.append(boundingCurves.inner[i])
            normals.append(boundingCurves.outer[i])
        }
        return normals
    }
}
