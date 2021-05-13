//
//  ZigZaggery.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-17.
//

import Foundation
import SwiftUI

typealias ZigZagDeltas = (inner: CGFloat, outer: CGFloat)

struct ZigZagger {
    
    let baseCurve : BaseCurvePairs
    let offsets : Offsets
    let zzDeltas : ZigZagDeltas
    var nilDeltas : [CGFloat]
    
    init(baseCurve: BaseCurvePairs,
         offsets: Offsets,
         limits: ZigZagDeltas) {
        
        self.baseCurve = baseCurve
        self.offsets = offsets
        
        zzDeltas = limits
        nilDeltas = [CGFloat](repeating: 0, count: baseCurve.count)
    }

    //MARK:-
    func calculateZigZags(nextPhaseIsZig: Bool,
                          zigZagCurves: ZigZagCurves,
                          randomPerturbations: Bool) -> ZigZagCurves {
        
        if Model.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.calculateZigZagsForNextPhase()")
        }
        
        let deltas = randomPerturbations ?
                        randomDeltas(nextPhaseIsZig: nextPhaseIsZig) :
                        nilDeltas
        
        return nextPhaseIsZig ?
            (zig: calculateNewZig(using: deltas), zag: zigZagCurves.zag) :
            (zig: zigZagCurves.zig, zag: calculateNewZag(using: deltas))
    }
    
    func calculatePlainJaneZigZags() -> ZigZagCurves {
        
        return (calculateNewZig(using: nilDeltas),
                calculateNewZag(using: nilDeltas))
    }
    
    //MARK:-
    func randomPerturbation(within limits: CGFloat) -> CGFloat {
        return CGFloat.random(in: -abs(limits)...abs(limits))
    }
    
    func randomDeltas(nextPhaseIsZig: Bool) -> [CGFloat] {

        if Model.DEBUG_TRACK_ZIGZAG_PHASING {
            print("ZigZagger.randomDeltas()")
            print("..... blobLimits(.outer: +/- \(zzDeltas.outer)"
                    + ", .inner: \(zzDeltas.inner))")
        }
        if nextPhaseIsZig {
            return baseCurve.enumerated().map { // deltas for zig phase
                $0.0.isEven() ?
                    randomPerturbation(within: zzDeltas.outer) :
                    randomPerturbation(within: zzDeltas.inner)
            }
        }
        return baseCurve.enumerated().map { // deltas for zag phase
            $0.0.isEven() ?
                randomPerturbation(within: zzDeltas.inner) :
                randomPerturbation(within: zzDeltas.outer)
        }
    }
    
    //MARK:-
    func calculateNewZig(using deltas: [CGFloat]) -> [CGPoint] {
        let zig = baseCurve.enumerated().map {
            $0.1.0.newPoint(atOffset: $0.0.isEven() ?
                                offsets.outer + deltas[$0.0] :
                                offsets.inner + deltas[$0.0],
                            along: $0.1.1)
        }
         return zig
    }
    
    func calculateNewZag(using deltas: [CGFloat]) -> [CGPoint] {
        let zag = baseCurve.enumerated().map {
            $0.1.0.newPoint(atOffset: $0.0.isEven() ?
                                offsets.inner + deltas[$0.0]:
                                offsets.outer + deltas[$0.0],
                            along: $0.1.1)
        }
        return zag
    }
}
