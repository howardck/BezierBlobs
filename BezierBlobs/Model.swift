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

class Model: ObservableObject {
    
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
    // this will have been set up by the time we 1st get here...
    var offsets : Offsets = (inner: 0, outer: 0)
    var blobLimits : ZigZagDeltas = (inner: 0, outer: 0)
    var zigZagger : ZigZagger?

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
                
        zigZagger = ZigZagger(baseCurve: baseCurve,
                                      offsets: offsets,
                                      limits: blobLimits)
        zigZagCurves = zigZagger!.calculatePlainJaneZigZags()

        setInitialBlobCurve()
    }
    
    func animateToNextFixedZigZag() {
        
        print("NYI NYI NYI ")
    }

//    //MARK: - ANIMATING
//    func animateToNextZigZagPhase(doRandomDeltas: Bool) {
//        
//        self.doRandomDeltas = doRandomDeltas
//
//        zigZagCurves = zigZagger!.calculateZigZags(nextPhaseIsZig: nextPhaseIsZig,
//                                                   zigZagCurves: zigZagCurves,
//                                                   randomPerturbations: doRandomDeltas)
//        blobCurve = nextPhaseIsZig ?
//            zigZagCurves.zig :
//            zigZagCurves.zag
//        
//        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
//            print("Model.animateToNextZigZagPhase(). { nextPhaseIsZig = \(nextPhaseIsZig) }")
//        }
//        
//        nextPhaseIsZig.toggle()
//    }
//    
//
//    func animateToRandomOffsetsAnywhereWithinEnvelope() {
//        
//        blobCurve = baseCurve.map {
//            let r = CGFloat.random(in: -abs(offsets.inner)...abs(offsets.outer))
//            return $0.newPoint(atOffset: r, along: $1)
//        }
//    }
//    
//    func animateToOffsets( _ evenOffsets: CGFloat,
//                           _ oddOffsets: CGFloat) -> [CGPoint]
//    {
//        baseCurve.enumerated().map {
//            $0.1.0.newPoint(atOffset: $0.0.isEven() ?
//                                CGFloat.random(in: 0...abs(evenOffsets)) :
//                                CGFloat.random(in: -abs(oddOffsets)...0),
//                            along: $0.1.1)
//        }
//    }
//    
//    func animateToRandomOffsetsInAlternatingQuadrants() {
//        
//        blobCurve = nextPhaseIsZig ?
//            animateToOffsets(offsets.outer, offsets.inner) :
//            animateToOffsets(offsets.inner, offsets.outer)
//        
//        nextPhaseIsZig.toggle()
//    }
    
    //MARK:-
    //MARK:-

    var perturbationRange : ClosedRange<CGFloat> = -20...100

    func animateToRandomizedPerturbationInRange() {
        
        var isOffsetToOutside = nextPhaseIsZig
        var curve = [CGPoint]()
        
        for (_, vertexTuple) in baseCurve.enumerated() {
            
            let offset : CGFloat = isOffsetToOutside ?
                offsets.outer + CGFloat.random(in: perturbationRange) :
                offsets.inner + CGFloat.random(in: perturbationRange)
            
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
