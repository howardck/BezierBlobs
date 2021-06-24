//
//  PageDescriptors_TEST.swift
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
    var order: Double
    var numPoints: Int
    var axisRelOffsets: (inner: CGFloat, baseCurve: Double, outer: CGFloat)
    var axisRelDeltas: (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)
    var forceEqualAxes : Bool? = false
    
    static let circle = Self(pageType: .circle,
                             order: 2.0, numPoints: 22,
                             axisRelOffsets: (inner: 0.4, baseCurve: 0.6, outer: 0.9),
                             axisRelDeltas: (innerRange: -0.1..<0.2, outerRange: -0.3..<0.1),
                             forceEqualAxes: true)
    static let classicSE = Self(pageType: .classicSE,
                                order: 2.8, numPoints: 36,
                                axisRelOffsets: (inner: 0.4, baseCurve: 0.6, outer: 0.9),
                                axisRelDeltas: (innerRange: -0.1..<0.25, outerRange: -0.25..<0.1))
    static let deltaWing = Self(pageType: .deltaWing,
                                order: 3.0, numPoints: 6,
                                axisRelOffsets: (inner: 0.2, baseCurve: 0.4, outer: 0.75),
                                axisRelDeltas: (innerRange: 0..<0.1, outerRange: -0.25..<0.25))
    static let rorschach = Self(pageType: .rorschach,
                                order: 0.8, numPoints: 26,
                                axisRelOffsets: (inner: 0.4, baseCurve: 0.7, outer: 1.1),
                                axisRelDeltas: (innerRange: -0.1..<0.2, outerRange: -0.3..<0.2))
}

struct PageDescriptors_TEST: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PageDescriptors_TEST_Previews: PreviewProvider {
    static var previews: some View {
        PageDescriptors_TEST()
    }
}
