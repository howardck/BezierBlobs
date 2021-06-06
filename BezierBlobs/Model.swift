//
//  Model.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

typealias Axes = (a: Double, b: Double)
typealias Offsets = (inner: CGFloat, outer: CGFloat)

typealias BaseCurvePairs = [(vertex: CGPoint, normal: CGVector)]
typealias BoundingCurves = (inner: [CGPoint], outer: [CGPoint])

// DO I WANT TO KEEP/USE KEEP THESE ???????????????
typealias ZigZagCurves = (zig: [CGPoint], zag: [CGPoint])
typealias ZigZagDeltas = (inner: CGFloat, outer: CGFloat)

// the first, as a fraction of the baseCurve ratio, gets converted to the second
typealias AxisRelativePerturbationDeltas = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)

// the innerRange is centred on the innerCurve; the outerRange on the outerCurve
typealias PerturbationDeltas = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)

class Model: ObservableObject {
    
    // it's be easier to say a nilDelta == 0..<0, but that's a crasher
    static let NIL_DELTAS : Range<CGFloat> = 0..<CGFloat(SEParametrics.VANISHINGLY_SMALL_DOUBLE)
    
    var offsets : Offsets = (inner: 0, outer: 0)
    var perturbationDeltas : PerturbationDeltas = (innerRange: 0..<0,
                                                   outerRange: 0..<0)
    
    static let TEST_PERTURB_DELTA : Range<CGFloat> = -0.5..<0.5

    
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
    
   // @State
    var nextPhaseIsZig = true
  
    // MARK:-

    // our supporting cast
    var baseCurve : BaseCurvePairs = [(CGPoint, CGVector)]()
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    
    // EXPERIMENTAL ...
    var deltaExtremas = (innerExtrema: [CGPoint](), outerExtrema: [CGPoint]())
    
    // DITTO THE ABOVE. ie
    // DO I WANT TO KEEP/USE KEEP THESE ???????????????

    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]())
    
    var normalsCurve : [CGPoint] = [CGPoint]()
    var axes : Axes = (1.0, 1.0)

    var pageType: PageType?

    //MARK:- MAIN SUPERELLIPSE
    func calculateSuperEllipse(for pageType: PageType,
                               n: Double,
                               numPoints: Int,
                               axes: Axes) {
        self.pageType = pageType
        
        //print("Model.calculateSuperEllipse()")
        
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
        
        return (inner_inside: baseCurve.map{ $0.newPoint(atOffset: offsets.inner + insideBound, along: $1)},
         inner_outside: baseCurve.map{ $0.newPoint(atOffset: offsets.inner + outsideBound, along: $1)})
    }
    
    func EXPERIMENTAL_calculateFixedPerturbationBandsOuter() -> PerturbationBandCurves
    {
        let insideBound = perturbationDeltas.outerRange.lowerBound
        let outsideBound = perturbationDeltas.outerRange.upperBound
        return (outer_inside: baseCurve.map{ $0.newPoint(atOffset: offsets.outer + insideBound, along: $1)},
         outer_outside: baseCurve.map{ $0.newPoint(atOffset: offsets.outer + outsideBound, along: $1)})
    }

    //MARK:-
    func animateToNextFixedPerturbationDelta() {
        
        var isOffsetToOutside = nextPhaseIsZig
        var curve = [CGPoint]()
        
        for (_, vertexTuple) in baseCurve.enumerated() {
            
            let offset : CGFloat = isOffsetToOutside ?
                offsets.outer + perturbationDeltas.outerRange.upperBound :
                offsets.inner + perturbationDeltas.innerRange.upperBound
            
            let pt = vertexTuple.vertex.newPoint(atOffset: offset,
                                                 along: vertexTuple.normal)
            curve += [pt]
            isOffsetToOutside.toggle()
        }
        
        blobCurve = curve // we update blobCurve; drive the animation
        nextPhaseIsZig.toggle()
    }
    
    func animateToRandomizedPerturbation() {
        var curve = [CGPoint]()
        
        for (i, vertextNormal) in baseCurve.enumerated() {
            let offset = (i % 2) == 0 ?
                offsets.outer + CGFloat.random(in: perturbationDeltas.outerRange) :
                offsets.inner + CGFloat.random(in: perturbationDeltas.innerRange)
            let point = vertextNormal.vertex.newPoint(atOffset: offset, along: vertextNormal.normal)
            curve += [point]
        }
        blobCurve = curve
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
        (inner: baseCurve.map{ $0.newPoint(atOffset: offsets.inner, along: $1)},
         outer: baseCurve.map{ $0.newPoint(atOffset: offsets.outer, along: $1)})
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
