//
//  PageDescriptors_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-12.
//

import SwiftUI

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
