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
    let blobLimits : BlobPerturbationLimits
    var nilDeltas : [CGFloat]
    
    init(baseCurve: BaseCurvePairs,
         offsets: Offsets,
         limits: BlobPerturbationLimits) {
        
        self.baseCurve = baseCurve
        self.offsets = offsets
        
        blobLimits = limits
        nilDeltas = [CGFloat](repeating: 0, count: baseCurve.count)
    }

    //MARK:-
    func calculateZigZags(zigIsNextPhase: Bool,
                          zigZagCurves: ZigZagCurves,
                          randomPerturbations: Bool) -> ZigZagCurves {
        
        if Model.DEBUG_TRACK_ZIGZAG_PHASING {
            print("Model.calculateZigZagsForNextPhase()")
        }
        
        let deltas =                                                    randomPerturbations ?
                        randomDeltas(zigIsNextPhase: zigIsNextPhase) :
                        nilDeltas
        
        return zigIsNextPhase ?
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
    
    func randomDeltas(zigIsNextPhase: Bool) -> [CGFloat] {

        if Model.DEBUG_TRACK_ZIGZAG_PHASING {
            print("ZigZagger.randomDeltas()")
            print("..... blobLimits(.outer: +/- \(blobLimits.outer)"
                    + ", .inner: \(blobLimits.inner))")
        }
        
        let enumerated = baseCurve.enumerated()
        if zigIsNextPhase {
            
            return enumerated.map {
                $0.0.isEven() ?
                    randomPerturbation(within: blobLimits.outer) :
                    randomPerturbation(within: blobLimits.inner)
            }
        }
        // deltas for zag phase
        return enumerated.map {
            $0.0.isEven() ?
                randomPerturbation(within: blobLimits.inner) :
                randomPerturbation(within: blobLimits.outer)
        }
    }
    
    //MARK:-
    func calculateNewZig(using deltas: [CGFloat]) -> [CGPoint] {
        let enumerated = baseCurve.enumerated()
        let zig = enumerated.map {
            $0.1.0.newPoint(atOffset: $0.0.isEven() ?
                                offsets.outer + deltas[$0.0] :
                                offsets.inner + deltas[$0.0],
                            along: $0.1.1)
        }
         return zig
    }
    
    func calculateNewZag(using deltas: [CGFloat]) -> [CGPoint] {
        let enumerated = baseCurve.enumerated()
        let zag = enumerated.map {
            $0.1.0.newPoint(atOffset: $0.0.isEven() ?
                                offsets.inner + deltas[$0.0]:
                                offsets.outer + deltas[$0.0],
                            along: $0.1.1)
        }
        return zag
    }
}
