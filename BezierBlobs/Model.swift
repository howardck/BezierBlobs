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
typealias ZigZagCurves = (zig: [CGPoint], zag: [CGPoint])
typealias ZigZagDeltas = (inner: CGFloat, outer: CGFloat)

// the first, as a fraction of the baseCurve ratio, gets converted to the second
typealias AxisRelativePerturbationDeltas = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)

// the innerRange is centred on the innerCurve; the outerRange on the outerCurve
typealias PerturbationRanges = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)

class Model: ObservableObject {
    
    var nilDeltas : PerturbationRanges = (innerRange: 0..<0,
                                          outerRange: 0..<0)
    
    static let NIL_DELTAS : Range<CGFloat> = 0..<CGFloat(Parametrics.VANISHINGLY_SMALL_DOUBLE)
    
    var perturbationRanges : PerturbationRanges = (innerRange: 0..<0,
                                                   outerRange: 0..<0)
    
    static let TEST_PERTURB_DELTA : Range<CGFloat> = -0.5..<0.5

    
    //MARK:-
    init() {
        print("Model.init()")
    }
    
    //MARK:-
    
    static let DEBUG_PRINT_PAGEVIEW_INIT_BASIC_AXIS_PARAMS = false
    static let DEBUG_PRINT_BASIC_SE_PARAMS = false
    static let DEBUG_PRINT_VERTEX_NORMALS = false
    static let DEBUG_TRACK_ZIGZAG_PHASING = false
    static let DEBUG_PRINT_RANDOMIZED_OFFSET_CALCS = true
    static let DEBUG_ADJUST_PERTURBATION_LIMITS = true
    
    
    //MARK:-
    
    @Published var blobCurve = [CGPoint]()
    @Published var numPoints: Int = 0
         
    // zig vs zag configurations:
    // zig : green vertex[0] marker moves to the outside
    // zag : green vertex[0] marker moves to the inside
    
    @State var nextPhaseIsZig = true
  
    // MARK:-
    var pageDescription: PageDescription!
    
    var baseCurve : BaseCurvePairs = [(CGPoint, CGVector)]()
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]())
    var normalsCurve : [CGPoint] = [CGPoint]()
    var axes : Axes = (1.0, 1.0)

    var pageType: PageType?

    var offsets : Offsets = (inner: 0, outer: 0)


    //MARK:- MAIN SUPERELLIPSE
    func calculateSuperEllipse(for pageType: PageType,
                               pageDescription: PageDescription,
                               axes: Axes) {
        self.pageDescription = pageDescription
        
        self.axes = axes
        self.numPoints = pageDescription.numPoints
        self.pageType = pageType
         
        baseCurve = Parametrics.calculateSuperEllipse(for: numPoints,
                                                      n: pageDescription.n,
                                                      with: axes)
    }
    
    func recalculateFor(newNumPoints: Int) {
        
        self.numPoints = newNumPoints
        baseCurve = Parametrics.calculateSuperEllipse(for: self.numPoints,
                                                      n: self.pageDescription.n,
                                                      with: self.axes)
        calculateSupportCurves()
    }
    
    //MARK:- SUPPORT CURVES
    func calculateSupportCurves() {
        
        boundingCurves = calculateBoundingCurves(using: offsets)
        normalsCurve = calculateNormals()

        setInitialBlobCurve()
    }
    
    func animateToNextFixedZigZag() {
        
        print("NYI NYI NYI ")
    }
    
    //MARK:-
    //MARK:-

    //var perturbationRange : Range<CGFloat> = -20..<100

    func animateToRandomizedPerturbationInRange() {
        
        var isOffsetToOutside = nextPhaseIsZig
        var curve = [CGPoint]()
        
        for (_, vertexTuple) in baseCurve.enumerated() {
            
            let offset : CGFloat = isOffsetToOutside ?
                offsets.outer + CGFloat.random(in: perturbationRanges.outerRange) :
                offsets.inner + CGFloat.random(in: perturbationRanges.innerRange)
            
            let pt = vertexTuple.vertex.newPoint(atOffset: offset,
                                                 along: vertexTuple.normal)
            curve += [pt]
            isOffsetToOutside.toggle()
        }
        
        blobCurve = curve // we update blobCurve; drive the animation
        nextPhaseIsZig.toggle()
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
        for i in 0..<numPoints {
            normals.append(boundingCurves.inner[i])
            normals.append(boundingCurves.outer[i])
        }
        return normals
    }
}
