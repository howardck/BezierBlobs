//
//  PageDescriptors.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-12.
//

import SwiftUI

struct PageDescriptors {
    
    enum PageType: String {
        case circle = "CIRCLE"
        case classicSE = "CLASSIC SE"
        case deltaWing = "DELTA WING"
        case rorschach = "RORSCHACH"
    }
    
    var pageType: Self.PageType
    var n: Double
    var numPoints: Int
    var axisRelOffsets: (inner: CGFloat, baseCurve: Double, outer: CGFloat)
    var axisRelDeltas: (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)
        
    static let deltaWing = Self(pageType: .deltaWing,
                                n: 3.0, numPoints: 6,
                                axisRelOffsets: (inner: 0.2, baseCurve: 0.6, outer: 0.75),
                                axisRelDeltas: (innerRange: -0.1..<0.1, outerRange: -0.25..<0.275))
    
    static let circle = Self(pageType: .circle,
                             n: 2.0, numPoints: 24,
                             axisRelOffsets: (inner: 0.4, baseCurve: 0.7, outer: 0.85),
                             axisRelDeltas: (innerRange: -0.1..<0.2, outerRange: -0.3..<0.2))
    
    static let classicSE = Self(pageType: .classicSE,
                                n: 3.4, numPoints: 38,
                                axisRelOffsets: (inner: 0.3, baseCurve: 0.6, outer: 0.85),
                                axisRelDeltas: (innerRange: 0.05..<0.3, outerRange: -0.3..<0.1))

    static let rorschach = Self(pageType: .rorschach,
                                n: 0.8, numPoints: 26,
                                axisRelOffsets: (inner: 0.3, baseCurve: 0.75, outer: 1.0),
                                axisRelDeltas: (innerRange: -0.1..<0.3, outerRange: -0.3..<0.25))
}
