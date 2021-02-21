//
//  ZigZaggery.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-17.
//

import Foundation
import SwiftUI

struct ZigZagManager {
    
    let baseCurve : BaseCurvePairs
    let offsets : Offsets
    let perturbationLimits : PerturbationLimits
    
    init(baseCurve: BaseCurvePairs,
         offsets: Offsets,
         limits: PerturbationLimits) {
        
        self.baseCurve = baseCurve
        self.offsets = offsets
        self.perturbationLimits = limits
    }
    /*  BUG w/ new ZigZagManager:
        assumes zigZag
     */
    func calculateZigZags(zigIsNextPhase: Bool,
                          zigZagCurves: ZigZagCurves) -> ZigZagCurves {
        let deltas = randomPerturbationDeltas(zigIsNextPhase: zigIsNextPhase)
        
        return zigIsNextPhase ?
            (zig: calculateNewZig(using: deltas), zag: zigZagCurves.zag) :
            (zig: zigZagCurves.zig, zag: calculateNewZag(using: deltas))
    }
    
    func randomPerturbation(within limits: CGFloat) -> CGFloat {
        return CGFloat.random(in: -abs(limits)...abs(limits))
    }
    
    func randomPerturbationDeltas(zigIsNextPhase: Bool) -> [CGFloat] {

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
}
