//
//  ZigZaggery.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-17.
//

import Foundation
import SwiftUI

struct ZigZagger {
    
    let baseCurve : BaseCurvePairs
    let offsets : Offsets
    let perturbationLimits : PerturbationLimits
    var nilDeltas = [CGFloat]()
    
    init(baseCurve: BaseCurvePairs,
         offsets: Offsets,
         limits: PerturbationLimits) {
        
        self.baseCurve = baseCurve
        self.offsets = offsets
        self.perturbationLimits = limits
        
        self.nilDeltas = [CGFloat](repeating: 0, count: baseCurve.count)
    }

    //MARK:-
    func calculateZigZags(zigIsNextPhase: Bool,
                          zigZagCurves: ZigZagCurves,
                          randomPermutations: Bool) -> ZigZagCurves {
        
        if Model.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.calculateZigZagsForNextPhase()")
        }
        
        let deltas = randomPermutations ?
                        randomDeltas(zigIsNextPhase: zigIsNextPhase) :
                        nilDeltas
        
        return zigIsNextPhase ?
            (zig: calculateNewZig(using: deltas), zag: zigZagCurves.zag) :
            (zig: zigZagCurves.zig, zag: calculateNewZag(using: deltas))
    }
    
    //MARK:-
    func randomPerturbation(within limits: CGFloat) -> CGFloat {
        return CGFloat.random(in: -abs(limits)...abs(limits))
    }
    
    func randomDeltas(zigIsNextPhase: Bool) -> [CGFloat] {

        if Model.DEBUG_TRACK_ZIGZAG_PHASING {
            print("ZigZagger.randomDeltas()")
            print("..... perturbationLimits(.outer: +/- \(perturbationLimits.outer)"
                    + ", .inner: \(perturbationLimits.inner))")
        }
        
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
    
    //MARK:-
    func calculateNewZig(using deltas: [CGFloat]) -> [CGPoint] {
        let enumerated = baseCurve.enumerated()
        let zig = enumerated.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer + deltas[$0.0] :
                                offsets.inner + deltas[$0.0],
                            along: $0.1.1)
        }
         return zig
    }
    
    func calculateNewZag(using deltas: [CGFloat]) -> [CGPoint] {
        let enumerated = baseCurve.enumerated()
        let zag = enumerated.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner + deltas[$0.0]:
                                offsets.outer + deltas[$0.0],
                            along: $0.1.1)
        }
        return zag
    }
    //MARK:-
    // initial plain-jane unperturbed zigZag generator. leave in for comparison
    // to newer, more generalized version that uses param randomPermutations: false.

    func calculatePlainJaneZigZags() -> ZigZagCurves {
        let enumerated = baseCurve.enumerated()
        let zig = enumerated.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.outer :
                                offsets.inner,
                            along: $0.1.1)
        }
        let zag = enumerated.map {
            $0.1.0.newPoint(at: $0.0.isEven() ?
                                offsets.inner :
                                offsets.outer,
                            along: $0.1.1)
        }
        return (zig, zag)
    }
}
