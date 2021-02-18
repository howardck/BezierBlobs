//
//  Model.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

typealias Axes = (a: Double, b: Double)
typealias Offsets = (inner: CGFloat, outer: CGFloat)
typealias PerturbationLimits =  (inner: CGFloat, outer: CGFloat)

typealias BaseCurvePairs = [(vertex: CGPoint, normal: CGVector)]
typealias BoundingCurves = (inner: [CGPoint], outer: [CGPoint])
typealias ZigZagCurves = (zig: [CGPoint], zag: [CGPoint])


class Model: ObservableObject { // init() { print("Model.init()") }
    
    static let DEBUG_PRINT_BASIC_SE_PARAMS = false
    static let DEBUG_PRINT_VERTEX_NORMALS = false
    static let DEBUG_TRACK_ZIGZAG_PHASING = false
    static let DEBUG_PRINT_RANDOMIZED_OFFSET_CALCS = false
    static let DEBUG_ADJUST_PERTURBATION_LIMITS = false
    
    @Published var blobCurve = [CGPoint]()
    
    // at vertex 0
    // zig configuration moves to the outside
    // zag configuration moves to the inside
    
    // ZIG == vertex[0] moves to the outside first
    // ZAG == vertex[0] moves to the inside first
    var zigIsNextPhase = true
    
    static let VANISHINGLY_SMALL_DOUBLE = 0.000000000000000001  // kludge ahoy?
        
    // MARK:-
    var baseCurve : BaseCurvePairs = [(CGPoint, CGVector)]()
    var boundingCurves : BoundingCurves = (inner: [CGPoint](), outer: [CGPoint]())
    var zigZagCurves : ZigZagCurves = (zig: [CGPoint](), zag: [CGPoint]())
    var normalsCurve : [CGPoint] = [CGPoint]()
    
    //MARK:-
    //TODO: TODO: (maybe) OFFSETS SHOULD BE A PLATFORM-SPECIFIC SCREEN RATIO
    
    var axes : Axes = (1, 1)
    var numPoints: Int = 0
    var offsets : Offsets = (inner: 0, outer: 0)
    
    var perturbationLimits : PerturbationLimits = (inner: 0, outer: 0)
    
    //MARK: - ANIMATE TO ZIG-ZAGS
    func animateToNextZigZagPhase() {
        
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.animateToNextZigZagPhase():: animateToZig == {\(zigIsNextPhase)}")
        }

        zigZagCurves = calculateZigZagsForNextPhase()
        
        blobCurve = zigIsNextPhase ?
            zigZagCurves.zig :
            zigZagCurves.zag

        zigIsNextPhase.toggle()
    }

    func animateToCurrZigZagPhase() {
        blobCurve = zigIsNextPhase ?
            zigZagCurves.zag :
            zigZagCurves.zig
    }
    
    //MARK:-
    func setInitialBlobCurve() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.setInitialBlobCurve(PageType.\(pageType!.rawValue))" )
        }
        blobCurve = baseCurve.map{ $0.vertex }
    }
    
    func returnToInitialConfiguration() {
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.returnToInitialConfiguration(PageType.\(pageType!.rawValue))" )
        }
        zigIsNextPhase = true
        
        // recalculate with 0 perturbations
        zigZagCurves = calculatePlainJaneZigZags()
        blobCurve = baseCurve.map{ $0.vertex }
    }
       
    //MARK:-
    var pageType: PageType?

    //MARK:-
    func calculateSuppportCurves(for pageType: PageType,
                                 pageDescription: PageDescription,
                                 axes: Axes) {
        self.pageType = pageType
        self.perturbationLimits = pageDescription.perturbLimits
        self.numPoints = pageDescription.numPoints
        
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

        self.baseCurve = calculateSuperEllipse(for: self.numPoints,
                                            n: pageDescription.n,
                                            with: self.axes)
        
        if Self.DEBUG_PRINT_BASIC_SE_PARAMS {
            print("Model.calculateSuperEllipseCurves(PageType.\(pageType.rawValue))")
            print("  numPoints: {\(numPoints)} ")
            print("  axes: (a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))})")
            print("  offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
        }
        
        self.perturbationLimits = upscale(perturbationLimits, toMatch: offsets)
        
        // ---------------------------------------------------------
        boundingCurves = calculateBoundingCurves(using: self.offsets)
        normalsCurve = calculateNormalsPseudoCurve()
        
        self.zigZagManager = ZigZagManager(baseCurve: baseCurve,
                                           offsets: offsets,
                                           zigZagCurves: zigZagCurves,
                                           limits: perturbationLimits)
        
        zigZagCurves = calculatePlainJaneZigZags()
        // ----------------------------------------------------------

        if ContentView.StatusTracker.isUninitialzed(pageType: pageType) {
            setInitialBlobCurve()
            ContentView.StatusTracker.markInited(pageType: pageType)
        }
        else {
            animateToCurrZigZagPhase()
        }
    }
    
    var zigZagManager : ZigZagManager
    
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
    
    
    //MARK: - ZIG-ZAGS
/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    // NOTA: we only want to change one of them, not both
    func calculateZigZagsForNextPhase() -> ZigZagCurves {
        let deltas = randomPerturbationDeltas()
        return zigIsNextPhase ?
            (zig: calculateNewZig(using: deltas), zag: zigZagCurves.zag) :
            (zig: zigZagCurves.zig, zag: calculateNewZag(using: deltas))
    }
    
    func randomPerturbation(within limits: CGFloat) -> CGFloat {
        return CGFloat.random(in: -abs(limits)...abs(limits))
    }
    
    func randomPerturbationDeltas() -> [CGFloat] {

        let enumerated = baseCurve.enumerated()
        if zigIsNextPhase {
            
            // deltas for zig phase
            return enumerated.map {
                $0.0.isEven() ?
                    randomPerturbation(within: perturbationLimits.outer) :
                    randomPerturbation(within: perturbationLimits.inner)
            }
            
        }
        // deltas for zag phase
        return enumerated.map {
            $0.0.isEven() ?
                randomPerturbation(within: perturbationLimits.inner) :
                randomPerturbation(within: perturbationLimits.outer)
        }
    }
    
    func calculateNewZig(using deltas: [CGFloat]) -> [CGPoint] {
        let enumerated = self.baseCurve.enumerated()
        let zig = enumerated.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer + deltas[$0.0] :
                                offsets.inner + deltas[$0.0],
                            along: $0.1.1)
        }
         return zig
    }
    
    func calculateNewZag(using deltas: [CGFloat]) -> [CGPoint] {
        let enumerated = self.baseCurve.enumerated()
        let zag = enumerated.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner + deltas[$0.0]:
                                offsets.outer + deltas[$0.0],
                            along: $0.1.1)
        }
        return zag
    }

    // initial plain-jane unperturbed variety
    func calculatePlainJaneZigZags() -> ZigZagCurves {

        let z = baseCurve.enumerated()
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
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */
    
    // MARK:- OTHER CURVES
    
    func calculateBoundingCurves(using offsets: Offsets) -> BoundingCurves {
        
         (inner: baseCurve.map{ $0.newPoint(at: offsets.inner, along: $1)},
          outer: baseCurve.map{ $0.newPoint(at: offsets.outer, along: $1)})
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
