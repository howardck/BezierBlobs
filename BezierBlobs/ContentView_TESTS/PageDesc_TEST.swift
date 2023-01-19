//
//  PageDesc_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-06.
//

import SwiftUI

typealias RelativeOffsets = (inner: CGFloat, BaseCurve: Double, outer: CGFloat)
typealias ZigZagRandomDeltas = (inner: CGFloat, outer: CGFloat)

typealias PageDesc = (numPoints : Int, n : Double,
                      axisRelOffsets : RelativeOffsets,
                      zzDeltas : ZigZagRandomDeltas,
                      forceEqualAxes : Bool)
enum PerturbType {
    case zigZagBased
    case envelopeBased
}

struct PageDescs {
    static let ZZ_DELTAS_UNUSED : ZigZagRandomDeltas = (inner: -999999, outer: -99999)
    static let pages : [PerturbType : [PageDesc] ] =
    [
        .zigZagBased :
            [
            // CLASSIC SE
                (numPoints : 36, n : 3.8, axisRelOffsets: (inner: 0.5, BaseCurve: 0.6, outer: 0.8),
                    zzDeltas : (inner: 1.0, outer: 0.8), false),
            // CIRCLE
                (numPoints : 14, n : 2.0, axisRelOffsets: (inner: 0.5, BaseCurve: 0.75, outer: 1.0),
                    zzDeltas : (inner: 10, outer: 10), forceEqualAxes: true),
            // DELTA WING
                (numPoints : 6, n : 3.0, axisRelOffsets: (inner: 0.15, BaseCurve: 0.6, outer: 0.95),
                    zzDeltas : (inner: 0.0, outer: 0.0), false), // == fixed zigZags
            // MUTANT MOTH
                (numPoints : 24, n : 1.0, axisRelOffsets: (inner: 0.5, BaseCurve: 0.6, outer: 0.9),
                    zzDeltas : (inner: 10, outer: 10), false)
            ],
        .envelopeBased :
            [
            // CLASSIC SE
                (numPoints : 66, n : 3.8, axisRelOffsets: (inner: 0.4, BaseCurve: 0.6, outer: 1.0),
                    zzDeltas : PageDescs.ZZ_DELTAS_UNUSED, false),
            // CIRCLE
                (numPoints : 30, n : 2.0, axisRelOffsets: (inner: 0.5, BaseCurve: 0.75, outer: 1.0),
                    zzDeltas : PageDescs.ZZ_DELTAS_UNUSED, forceEqualAxes : true),
            // DELTA WING
                (numPoints: 12, n : 3.0, axisRelOffsets: (inner: 0.5, BaseCurve: 0.75, outer: 1.0),
                    zzDeltas : PageDescs.ZZ_DELTAS_UNUSED, false),
            // MUTANT MOTH
                (numPoints: 50, n : 1.0, axisRelOffsets: (inner: 0.4, BaseCurve: 0.5, outer: 1.1),
                    zzDeltas : PageDescs.ZZ_DELTAS_UNUSED, false)
            ]
    ]
}

struct PageDescTEST: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct PageDescTEST_Previews: PreviewProvider {
    static var previews: some View {
        PageDescTEST()
    }
}
