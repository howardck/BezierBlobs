//
//  Model.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

typealias Axes = (a: Double, b: Double)
typealias Offsets = (inner: CGFloat, outer: CGFloat)
typealias BlobPerturbationLimits =  (inner: CGFloat, outer: CGFloat)

typealias BaseCurvePairs = [(vertex: CGPoint, normal: CGVector)]
typealias BoundingCurves = (inner: [CGPoint], outer: [CGPoint])
typealias ZigZagCurves = (zig: [CGPoint], zag: [CGPoint])

class Model: ObservableObject {
    
    init() {
//        print("Model.init( zigIsNextPhase = {\(zigIsNextPhase)} )")
    }
    
    static let DEBUG_PRINT_BASIC_SE_PARAMS = true
    static let DEBUG_PRINT_VERTEX_NORMALS = false
    static let DEBUG_TRACK_ZIGZAG_PHASING = false
    static let DEBUG_PRINT_RANDOMIZED_OFFSET_CALCS = false
    static let DEBUG_ADJUST_PERTURBATION_LIMITS = false
    
    @Published var blobCurve = [CGPoint]()
         
    // at vertex 0:
    // zig configuration moves to the outside
    // zag configuration moves to the inside
    
    var zigIsNextPhase = true
    var doRandomDeltas = true
            
    // MARK:-
    var baseCurve : BaseCurvePairs = [(CGPoint, CGVector)]()
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]())
    var normalsCurve : [CGPoint] = [CGPoint]()
    
    //MARK:-
    //TODO: TODO: (maybe) OFFSETS SHOULD BE A PLATFORM-SPECIFIC SCREEN RATIO
    
    var axes : Axes = (1.0, 1.0)
    var numPoints: Int = 0
    var offsets : Offsets = (inner: 0, outer: 0)
    
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    var newStyleOffsets : Offsets = (inner: 0, outer: 0)
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    var pageType: PageType?
    var blobLimits : BlobPerturbationLimits = (inner: 0, outer: 0)
    
    var zigZagger : ZigZagger?
    
    //MARK:-
    func calculateSuperEllipseCurvesFamily(for pageType: PageType,
                                           pageDescription: PageDescription,
                                           axes: Axes) {
        massageParameters(pageType: pageType,
                          pageDescription: pageDescription,
                          axes: axes)
        
        baseCurve = calculateSuperEllipse(for: numPoints,
                                          n: pageDescription.n,
                                          with: self.axes)
        boundingCurves = calculateBoundingCurves(using: offsets)
        normalsCurve = calculateNormals()
        
        zigZagger = ZigZagger(baseCurve: baseCurve,
                                      offsets: offsets,
                                      limits: blobLimits)
        zigZagCurves = zigZagger!.calculatePlainJaneZigZags()

        setInitialBlobCurve()
    }
    
    //MARK: - NEW STYLE OFFSETS
    
    func calculateNewStyleOffsets(ratios: Offsets,
                                  baseCurve : CGFloat,
                                  against axisSize: CGFloat) -> Offsets
    {
        return (-99, 99)
    }

    //MARK: - ANIMATE TO ZIG-ZAGS

    func animateToNextZigZagPhase(doRandom: Bool) {

        zigZagCurves = zigZagger!.calculateZigZags(zigIsNextPhase: zigIsNextPhase,
                                                   zigZagCurves: zigZagCurves,
                                                   randomPermutations: doRandom)
        blobCurve = zigIsNextPhase ?
            zigZagCurves.zig :
            zigZagCurves.zag
        
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.animateToNextZigZagPhase(). { zigIsNextPhase = \(zigIsNextPhase) }")
        }

        zigIsNextPhase.toggle()
    }
    
    //MARK:-
    func setInitialBlobCurve() {
        
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.setInitialBlobCurve(PageType.\(pageType!.rawValue))" )
        }
        blobCurve = baseCurve.map{ $0.vertex }
    }
    
    func returnToInitialConfiguration() {

        setInitialBlobCurve()
        zigIsNextPhase = true
    }
    
    //MARK:-
    func massageParameters(pageType: PageType,
                           pageDescription: PageDescription,
                           axes: Axes) {
        self.pageType = pageType
        self.numPoints = pageDescription.numPoints
        
        print("Model.massageParameters(). " +
            "axes: ( a: {\((axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((axes.b).format(fspec: "6.2"))})")
        
        self.axes = axes
        let minAxis = max(axes.a, axes.b)

        if pageDescription.forceEqualAxes {
            self.axes = (a: minAxis, b: minAxis)
        }
        
        
//        offsets = (inner: CGFloat(minAxis) * pageDescription.offsets.in,
//                   outer: CGFloat(minAxis) * pageDescription.offsets.out)
        
        
        
        self.blobLimits = upscale(pageDescription.blobLimits,
                                  toMatch: offsets)
        
        if Self.DEBUG_PRINT_BASIC_SE_PARAMS {
            print("Basic SuperEllipse params for: (PageType.\(pageType.rawValue))")
            print("  numPoints: {\(numPoints)} ")
            print("  axes: (a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))})")
            print("  offsets: [OLD STYLE] (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            print("  offsets: [NEW STYLE] (inner: \(newStyleOffsets.inner.format(fspec: "6.2")), outer: \(newStyleOffsets.outer.format(fspec: "6.2")))")
            print("  blobLimits: " +
                    "( inner: {+/- \(blobLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {+/- \(blobLimits.outer.format(fspec: "4.2"))} ) ")
        }
    }
        
    func upscale(_ blobLimits: BlobPerturbationLimits,
                 toMatch offsets: Offsets) -> BlobPerturbationLimits
    {
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("Model.upscale(blobLimits)")
            print("offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            
            print("blobLimits before upscaling : ( inner: {\(blobLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {\(blobLimits.outer.format(fspec: "4.2"))} ) "
                  )
        }
        let pLimits = (inner: abs(blobLimits.inner * offsets.inner),
                       outer: abs(blobLimits.outer * offsets.outer))
        
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("blobLimits after  upscaling : " +
                    "( inner: {+/- \(pLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {+/- \(pLimits.outer.format(fspec: "4.2"))} ) ")
        }
        return pLimits
    }
    
    // MARK:- OTHER CURVES
    
    func calculateBoundingCurves(using offsets: Offsets) -> BoundingCurves {
        
        print("Model.calculateBoundingCurves(). offset.outer: \(offsets.outer)" )
        
        return
            (inner: baseCurve.map{ $0.newPoint(at: offsets.inner, along: $1)},
             outer: baseCurve.map{ $0.newPoint(at: offsets.outer, along: $1)})
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
