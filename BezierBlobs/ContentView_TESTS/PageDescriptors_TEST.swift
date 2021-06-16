//
//  PageDescriptors_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-12.
//

import SwiftUI

struct Descriptor {
    
    enum PageType : String {
        case circle = "CIRCLE"
        case classicSE = "CLASSIC SE"
        case deltaWing = "DELTA WING"
        case rorschach = "RORSCHACH"
    }
    
    var pageType: Descriptor.PageType
    var order: Double
    var numPoints: Int
    var axisRelOffsets: (inner: CGFloat, baseCurve: CGFloat, outer: CGFloat)
    var axisRelDeltas: (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>)
    var forceEqualAxes : Bool? = false
    
    static let allDescriptors : [Descriptor] = [
        .circle,
        .classicSE,
        .deltaWing,
        .rorschach
    ]
    
    static let circle = Self(pageType: .circle,
                             order: 2.0, numPoints: 22,
                             axisRelOffsets: (inner: 0.4, baseCurve: 0.6, outer: 0.8),
                             axisRelDeltas: (innerRange: -0.1..<0.15, outerRange: -0.3..<0.1),
                             forceEqualAxes: true)
    static let classicSE = Self(pageType: .classicSE,
                                order: 2.8, numPoints: 34,
                                axisRelOffsets: (inner: 0.45, baseCurve: 0.6, outer: 0.85),
                                axisRelDeltas: (innerRange: -0.1..<0.2, outerRange: -0.2..<0.1))
    static let deltaWing = Self(pageType: .deltaWing,
                                order: 3.0, numPoints: 6,
                                axisRelOffsets: (inner: 0.2, baseCurve: 0.4, outer: 0.75),
                                axisRelDeltas: (innerRange: -0.1..<0.1, outerRange: -0.25..<0.25))
    static let rorschach = Self(pageType: .rorschach,
                                order: 0.8, numPoints: 26,
                                axisRelOffsets: (inner: 0.35, baseCurve: 0.6, outer: 0.8),
                                axisRelDeltas: (innerRange: -0.1..<0.2, outerRange: -0.3..<0.2))
}

/*
    an alternative approach (not pursued) using the PageType enum as a dict key
 */

struct PageDescriptors {
    
    static let descriptorsForPagesDictionary :
        
        [ PageType : (order: Double, numPoints: Int,
                      axisRelOffsets: (inner: CGFloat, baseCurve: CGFloat, outer: CGFloat),
                      axisRelDeltas : (innerRange: Range<CGFloat>, outerRange: Range<CGFloat>),
                      forceEqualAxes: Bool) ] =
        
        [ .circle:
            (order: 2.0, numPoints: 22,
             axisRelOffsets: (inner: 0.25, baseCurve: 0.5, outer: 0.7),
             axisRelDeltas: (innerRange: 0.1..<0.3, outerRange: -0.3..<0.3),
             forceEqualAxes: true),
          
          .classicSE:
            (order: 2.0, numPoints: 22,
             axisRelOffsets: (inner: 0.25, baseCurve: 0.5, outer: 0.7),
             axisRelDeltas: (innerRange: 0.1..<0.3, outerRange: -0.3..<0.3),
             forceEqualAxes: true),
          
          .deltaWing:
            (order: 2.0, numPoints: 22,
             axisRelOffsets: (inner: 0.25, baseCurve: 0.5, outer: 0.7),
             axisRelDeltas: (innerRange: 0.1..<0.3, outerRange: -0.3..<0.3),
             forceEqualAxes: true),
          
          .rorschach:
            (order: 2.0, numPoints: 22,
             axisRelOffsets: (inner: 0.25, baseCurve: 0.5, outer: 0.7),
             axisRelDeltas: (innerRange: 0.1..<0.3, outerRange: -0.3..<0.3),
             forceEqualAxes: true)
        ]
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
