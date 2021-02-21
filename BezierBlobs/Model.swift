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

class Model: ObservableObject {
    
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
    var pageType: PageType?
    var perturbationLimits : PerturbationLimits = (inner: 0, outer: 0)
    
    var zigZagManager : ZigZagManager?
    
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
        
        self.zigZagManager = ZigZagManager(baseCurve: baseCurve,
                                           offsets: offsets,
                                           limits: perturbationLimits)
        
        zigZagCurves = zigZagManager!.calculatePlainJaneZigZags()

        if ContentView.StatusTracker.isUninitialzed(pageType: pageType) {
            setInitialBlobCurve()
            ContentView.StatusTracker.markInited(pageType: pageType)
        }
        else {
            animateToCurrZigZagPhase()
        }
    }
    
    func animateToCurrZigZagPhase() {
        
        blobCurve = zigIsNextPhase ?
            zigZagCurves.zag :
            zigZagCurves.zig
    }
    
    //MARK: - ANIMATE TO ZIG-ZAGS
    // called by PageView.onReceive(timer):
    func animateToNextZigZagPhase() {

        zigZagCurves = zigZagManager!.calculateZigZags(zigIsNextPhase: zigIsNextPhase,
                                                       zigZagCurves: zigZagCurves)
        blobCurve = zigIsNextPhase ?
            zigZagCurves.zig :
            zigZagCurves.zag

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
        if Self.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.returnToInitialConfiguration(PageType.\(pageType!.rawValue))" )
        }
        zigIsNextPhase = true
        
        // recalculate with 0 perturbations
        zigZagCurves = zigZagManager!.calculatePlainJaneZigZags()
        blobCurve = baseCurve.map{ $0.vertex }
    }
    
    func massageParameters(pageType: PageType,
                           pageDescription: PageDescription,
                           axes: Axes) {
        self.pageType = pageType
        self.numPoints = pageDescription.numPoints
        
        // #####################################
        // REVIEW IF THIS IS BEST WAY TO DO THIS ...
        // #####################################
        let radius = CGFloat((axes.a + axes.b)/2.0)
        self.axes = axes
        
        if pageDescription.forceEqualAxes {
            let minab = min(axes.a, axes.b)
            self.axes = (a: minab, b: minab)
        }
        offsets = (inner: radius * pageDescription.offsets.in,
                   outer: radius * pageDescription.offsets.out)
        
        self.perturbationLimits = upscale(pageDescription.perturbLimits,
                                          toMatch: offsets)
        
        if Self.DEBUG_PRINT_BASIC_SE_PARAMS {
            print("Basic SuperEllipse params for: (PageType.\(pageType.rawValue))")
            print("  numPoints: {\(numPoints)} ")
            print("  axes: (a: {\((self.axes.a).format(fspec: "6.2"))}, " +
                    "b: {\((self.axes.b).format(fspec: "6.2"))})")
            print("  offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            print("  perturbationLimits: " +
                    "( inner: {+/- \(perturbationLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {+/- \(perturbationLimits.outer.format(fspec: "4.2"))} ) ")
        }
    }
        
    func upscale(_ perturbLimits: PerturbationLimits,
                 toMatch offsets: Offsets) -> PerturbationLimits
    {
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("Model.upscale(perturbationLimits)")
            print("offsets: (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
            
            print("perturbationLimits before upscaling : ( inner: {\(perturbLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {\(perturbLimits.outer.format(fspec: "4.2"))} ) "
                  )
        }
        let pLimits = (inner: abs(perturbLimits.inner * offsets.inner),
                       outer: abs(perturbLimits.outer * offsets.outer))
        
        if Self.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("perturbationLimits after  upscaling : " +
                    "( inner: {+/- \(pLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {+/- \(pLimits.outer.format(fspec: "4.2"))} ) ")
        }
        return pLimits
    }
    
    // MARK:- OTHER CURVES
    
    func calculateBoundingCurves(using offsets: Offsets) -> BoundingCurves {
        
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
