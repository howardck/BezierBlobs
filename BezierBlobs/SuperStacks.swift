//
//  SuperStacks.swift
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
    .envelopeBounds :   (color: .black, radius: 8),
    .baseCurve :        (color: .white, radius: r),
    .zig :              (color: .green, radius : r),
    .zag :              (color: .red, radius: r)
]

struct AnimatingBlob: View {
    var curve: [CGPoint]
    
    let orangish = LinearGradient(gradient: Gradient(colors: [.blue, .init(white: 0.05)]),
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
    var body : some View {
        ZStack {
            
        // FILLED
        SuperEllipse(curve: curve,
                     bezierType: .lineSegments,
                     smoothed: true)
            .fill(orangish)
            
        //STROKED
            SuperEllipse(curve: curve,
                         bezierType: .lineSegments,
                         smoothed: true)
                .stroke(Color.red, lineWidth: 6)

            SuperEllipse(curve: curve,
                         bezierType: .lineSegments,
                         smoothed: true)
                .stroke(Color.white, lineWidth: 0.8)
        }
    }
}

struct NormalsPlusMarkers : View {
    
    var pseudoCurve: [CGPoint]
    var markerCurves: BoundingCurves
    var style : MarkerStyle
    
    var body: some View {
        
        ZStack {
            SuperEllipse(curve: pseudoCurve,
                         bezierType: .normals_lineSegments)
                .stroke(Color.init(white: 0.85),
                        style: StrokeStyle(lineWidth: 6, dash: [0.75,4]))
            
            SuperEllipse(curve: markerCurves.inner,
                         bezierType: .markers(radius: style.radius))
                .fill(Color.black)
            
            SuperEllipse(curve: markerCurves.outer,
                         bezierType: .markers(radius: style.radius))
                .fill(Color.black)
        }
    }
}

struct ZigZag_Markers : View {
    var curves : ZigZagCurves
    var zigStyle : MarkerStyle
    var zagStyle : MarkerStyle
    
    var body : some View {
        
        SuperEllipse(curve: curves.zig,
                     bezierType: .markers(radius: zigStyle.radius + 2))
            .fill(Color.init(white: 0.3))
        SuperEllipse(curve: curves.zig,
                     bezierType: .markers(radius: zigStyle.radius))
            .fill(zigStyle.color)
        
        SuperEllipse(curve: curves.zag,
                     bezierType: .markers(radius: zagStyle.radius + 2))
            .fill(Color.init(white: 0.9))
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
    }
}

//struct SuperEllipseStacks_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimatingBlobLines(curve: )
//    }
//}
