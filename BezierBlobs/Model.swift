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
    
    //MARK:-
    init() {
        print("\nModel.init()")
    }
    
    //MARK:-
    
    static let DEBUG_PRINT_PAGEVIEW_INIT_BASIC_AXIS_PARAMS = false
    static let DEBUG_PRINT_BASIC_SE_PARAMS = false
    static let DEBUG_PRINT_VERTEX_NORMALS = false
    static let DEBUG_TRACK_ZIGZAG_PHASING = false
    static let DEBUG_PRINT_RANDOMIZED_OFFSET_CALCS = false
    static let DEBUG_ADJUST_PERTURBATION_LIMITS = false
    
    @Published var blobCurve = [CGPoint]()
         
    // at vertex 0:
    // zig configuration: green vertex[0] marker moves to the outside
    // zag configuration: green vertex[0] marker moves to the inside
    
    var nextPhaseIsZig = true
    var doRandomDeltas = true
            
    // MARK:-
    var baseCurve : BaseCurvePairs = [(CGPoint, CGVector)]()
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]())
    var normalsCurve : [CGPoint] = [CGPoint]()
    var axes : Axes = (1.0, 1.0)
    var numPoints: Int = 0
    var offsets : Offsets = (inner: 0, outer: 0)
    var pageType: PageType?
    var blobLimits : BlobPerturbationLimits = (inner: 0, outer: 0)
    var zigZagger : ZigZagger?
    
    var totallyRandomBlobbyCurve = [CGPoint]()
    
    //MARK:-
    func calculateSuperEllipseCurvesFamily(for pageType: PageType,
                                           pageDescription: PageDescription,
                                           axes: Axes) {
        
        print("Model.calculateSuperEllipseCurvesFamily({\"\(pageType.rawValue)\"})")

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

    //MARK: - ANIMATING
    func animateToNextZigZagPhase(doRandomDeltas: Bool) {
        
        self.doRandomDeltas = doRandomDeltas

        zigZagCurves = zigZagger!.calculateZigZags(nextPhaseIsZig: nextPhaseIsZig,
                                                   zigZagCurves: zigZagCurves,
                                                   randomPerturbations: doRandomDeltas)
        blobCurve = nextPhaseIsZig ?
            zigZagCurves.zig :
            zigZagCurves.zag
        
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.animateToNextZigZagPhase(). { nextPhaseIsZig = \(nextPhaseIsZig) }")
        }

        nextPhaseIsZig.toggle()
    }
    
    
    func animateToSemiRandomOffset() {
        
    }
    
    // each point generated will lie somewhere (anywhere)
    // between -offset.inner and +offset.outer
    
    func animateToTotallyRandomOffset() {
        
        blobCurve = baseCurve.map {
            let r = CGFloat.random(in: -abs(offsets.inner)...abs(offsets.outer))
            return $0.newPoint(atOffset: r, along: $1)
        }
    }
    
    func animateToAlternatingSemiRandomOffset() {
        
        if nextPhaseIsZig {
            blobCurve = baseCurve.enumerated().map {
                    $0.1.0.newPoint(atOffset: $0.0.isEven() ?
                                        // first point in .zig curve is in the outer envelope section
                                        CGFloat.random(in: 0...abs(offsets.outer)) :
                                        CGFloat.random(in: -abs(offsets.inner)...0),
                                    along: $0.1.1)
                }
            }
        else {
            blobCurve = baseCurve.enumerated().map {
                $0.1.0.newPoint(atOffset: $0.0.isEven() ?
                                    // first point in .zag curve is in the inner envelope section
                                    CGFloat.random(in: -abs(offsets.inner)...0) :
                                    CGFloat.random(in: 0...abs(offsets.outer)),
                                along: $0.1.1)
            }
        }
        nextPhaseIsZig.toggle()
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
        nextPhaseIsZig = true
    }
    
    //MARK:-
    func massageParameters(pageType: PageType,
                           pageDescription: PageDescription,
                           axes: Axes) {
        self.pageType = pageType
        self.numPoints = pageDescription.numPoints
        
        print("Model.massageParameters({\"\(pageType.rawValue)\"}) " +
            "axes: (a: {\((axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((axes.b).format(fspec: "6.2"))})")
        
        let minAxis = min(axes.a, axes.b)
        self.axes = pageDescription.forceEqualAxes ?
                        (a: minAxis, b: minAxis) :
                        axes

        self.blobLimits = scaleUp(pageDescription.blobLimits,
                                  toMatch: offsets)
        
        if Self.DEBUG_PRINT_BASIC_SE_PARAMS {
            print("Basic SuperEllipse params for: (PageType.\(pageType.rawValue))")
            print("  numPoints: {\(numPoints)} ")
            print("  axes: (a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))})")
//            print("  offsets: [OLD STYLE] (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            print("  offsets: [NEW STYLE] (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            print("  blobLimits: " +
                    "( inner: {+/- \(blobLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {+/- \(blobLimits.outer.format(fspec: "4.2"))} ) ")
        }
    }
        
    func scaleUp(_ blobLimits: BlobPerturbationLimits,
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
