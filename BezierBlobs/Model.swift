//
//  Model.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

typealias Axes = (a: Double, b: Double)
typealias BaseCurvePairs = [(vertex: CGPoint, normal: CGVector)]
typealias BoundingCurves = (inner: [CGPoint], outer: [CGPoint])
typealias Offsets = (inner: CGFloat, outer: CGFloat)
 
// the first form, given as relative percentages of the semiMinorAxis,
// gets converted to the second form, in absolute screen distances
typealias AxisRelativePerturbationDeltas = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)

// the innerRange is centred (more or less) on the inner curve, the outerRange on the outer
typealias PerturbationDeltas = (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)


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
    

    var pageType: PageDescriptors.PageType?
    
    func calculatePerturbationDeltas(descriptors: PageDescriptors, minAxis: CGFloat) {
        let relInRange = descriptors.axisRelDeltas.innerRange
        let relOutRange = descriptors.axisRelDeltas.outerRange
        
        let innerRange = (relInRange.lowerBound * minAxis)..<(relInRange.upperBound * minAxis)
        let outerRange = (relOutRange.lowerBound * minAxis)..<(relOutRange.upperBound * minAxis)

        perturbationDeltas = (innerRange: innerRange,
                              outerRange: outerRange)
    }

    //MARK:- SUPERELLIPSE
    func calculateSuperEllipse(n: Double,
                               numPoints: Int,
                               axes: Axes) {
        
        baseCurve = SEParametrics.calculateSuperEllipse(for: numPoints,
                                                        n: n,
                                                        with: axes)
    }
    
    func calculateSupportCurves() {
        
        boundingCurves = calculateBoundingCurves(using: offsets)
        normalsCurve = calculateNormals()
        
        setInitialBlobCurve()
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
                offsets.inner + perturbationDeltas.innerRange.lowerBound
            
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
        // export the zigzag state so that the next cycle
        // picks that up and starts in the proper 'direction'
        self.nextPhaseIsZig.toggle()
    }
    
    //MARK:-
    func setInitialBlobCurve() {
        
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
