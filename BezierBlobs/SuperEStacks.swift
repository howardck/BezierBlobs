//
//  SEStacks.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-14.
//

import SwiftUI
                           
let orangeish = Gradient(colors: [.yellow, .red])

enum MarkerType : CaseIterable {
    case blob
    case pointZero
    case envelopeBounds
    case baseCurve
    case zig
    case zag
}

typealias MarkerStyle = (color: Color, radius: CGFloat)

let r: CGFloat = 14
let markerStyles : [MarkerType : MarkerStyle] = [
    .blob :             (color: .blue, radius: r + 2),
    .pointZero :        (color: .yellow, radius : r + 2),
    .envelopeBounds :   (color: .black, radius: 6),
    .baseCurve :        (color: .white, radius: r - 2),
    .zig :              (color: .green, radius : r),
    .zag :              (color: .red, radius: r)
]

struct AnimatingBlob: View {
    var curve: [CGPoint]
    var style : LinearGradient

    var body : some View {
        ZStack {
//            SuperEllipse(curve: curve,
//                         bezierType: .lineSegments,
//                         smoothed: true)
//                .fill(style)
            
            SuperEllipse(curve: curve,
                         bezierType: .lineSegments,
                         smoothed: true)
                .stroke(style, lineWidth: 6)
            
            SuperEllipse(curve: curve,
                         bezierType: .lineSegments,
                         smoothed: true)
                .stroke(Color.white, lineWidth: 0.8)
        }
    }
}

struct Normals_Markers : View {
    var curves : BoundingCurves
    var style : MarkerStyle
    
    var body: some View {
        
        ZStack {
            SuperEllipse(curve: curves.inner,
                         bezierType: .markers(radius: style.radius))
                .fill(Color.black)
        }
        SuperEllipse(curve: curves.outer,
                     bezierType: .markers(radius: style.radius))
            .fill(Color.black)
    }
}

struct ZigZag_Markers : View {
    var curves : ZigZagCurves
    var zigStyle : MarkerStyle
    var zagStyle : MarkerStyle
    
    var body : some View {
        
        SuperEllipse(curve: curves.zig,
                     bezierType: .markers(radius: zigStyle.radius + 2))
            .fill(Color.black)
        SuperEllipse(curve: curves.zig,
                     bezierType: .markers(radius: zigStyle.radius))
            .fill(zigStyle.color)
        
        SuperEllipse(curve: curves.zag,
                     bezierType: .markers(radius: zagStyle.radius + 2))
            .fill(Color.white)
        SuperEllipse(curve: curves.zag,
                     bezierType: .markers(radius: zagStyle.radius))
            .fill(zagStyle.color)
    }
}

struct AnimatingBlob_Markers : View {
    var curve : [CGPoint]
    var style : MarkerStyle
    
    var body : some View {
        
        SuperEllipse(curve: curve,
                     bezierType: .markers(radius: style.radius + 1))
            .fill(Color.black)
        SuperEllipse(curve: curve,
                     bezierType: .markers(radius: style.radius))
            .fill(style.color)
        SuperEllipse(curve: curve,
                     bezierType: .markers(radius: 3))
            .fill(Color.white)
    }
}

struct BaseCurve_Markers : View {
    var curve : [CGPoint]
    var style : MarkerStyle
    
    var body : some View {
        
        ZStack {
            SuperEllipse(curve: curve,
                         bezierType: .markers(radius: style.radius + 1))
                .fill(Color.black)
            
            SuperEllipse(curve: curve,
                         bezierType: .markers(radius: style.radius))
                .fill(style.color)
            SuperEllipse(curve: curve,
                         bezierType: .markers(radius: 3))
                .fill(Color.black)
        }
    }
}

struct AnimatingBlob_PointZeroMarker: View {
    var animatingCurve: [CGPoint]
    var markerStyle : MarkerStyle

    var body : some View {
        SuperEllipse(curve: animatingCurve,
                     bezierType: .singleMarker(index: 0, radius: markerStyle.radius + 1),
                     smoothed: false)
            .fill(Color.black)
        
        SuperEllipse(curve: animatingCurve,
                     bezierType: .singleMarker(index: 0, radius: markerStyle.radius),
                                               smoothed: false)
            .fill(markerStyle.color)
        
        SuperEllipse(curve: animatingCurve,
                     bezierType: .singleMarker(index: 0, radius: 3),
                                               smoothed: false)
            .fill(Color.gray)
        
//            .fill(Color.black)
//        SuperEllipse(curve: animatingCurve,
//                     bezierType: .singleMarker(index: 0, radius: ORIGIN_MARKER.radius),
//                     smoothed: false)
//            .fill(ORIGIN_MARKER.color)
        
//        SuperEllipse(curve: animatingCurve,
//                     bezierType: .singleMarker(index: 0, radius: ORIGIN_MARKER.radius - 13),
//                     smoothed: false)
//            .fill(Color.white)
    }
}

//struct SuperEllipseStacks_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimatingBlobLines(curve: )
//    }
//}
