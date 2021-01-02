//
//  SELayerStacks.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-14.
//

import SwiftUI
                           
let orangeish = Gradient(colors: [.yellow, .red])

enum MarkerType : CaseIterable {
    case blob
    case vertexOrigin
    case envelopeBounds
    case baseCurve
    case zig
    case zag
}

typealias MarkerStyle = (color: Color, radius: CGFloat)

let r: CGFloat = 14
let markerStyles : [MarkerType : MarkerStyle] = [
    .blob :             (color: .blue, radius: r + 2),
    .vertexOrigin :     (color: .yellow, radius : r + 2),
    .envelopeBounds :   (color: .black, radius: 8),
    .baseCurve :        (color: .white, radius: r + 2),
    .zig :              (color: .red, radius : r - 3),
    .zag :              (color: .green, radius: r - 3)
]

let blueGradient = Gradient(colors: [.blue, .init(white: 0.025)])
let redGradient = Gradient(colors: [.red, .yellow])

//MARK:-
struct AnimatingBlob: View {
    var curve: [CGPoint]
    var stroked: Bool
    var filled: Bool
    
    let gradient = LinearGradient(gradient: blueGradient,
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing)
    var body : some View {
        ZStack {
            
            if filled {
                SuperEllipse(curve: curve,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .fill(gradient)
            }
            if stroked {
                SuperEllipse(curve: curve,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .stroke(Color.red, lineWidth: 10)
                
                SuperEllipse(curve: curve,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .stroke(Color.white, lineWidth: 0.75)
            }
        }
    }
}

//MARK:-

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

struct AnimatingBlob_VertexOriginMarker: View {
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
            .fill(Color.white)
    }
}

//MARK:-
struct NormalsPlusMarkers : View {
    
    var normals: [CGPoint]
    var markerCurves: BoundingCurves
    var style : MarkerStyle
    
    var body: some View {
        
        ZStack {
            // NORMALS
            SuperEllipse(curve: normals,
                         bezierType: .normals_lineSegs)
                .stroke(Color.init(white: 0.85),
                        style: StrokeStyle(lineWidth: 5, dash: [0.75,4]))
            
            // NORMALS INNER & OUTER MARKERS
            SuperEllipse(curve: markerCurves.inner,
                         bezierType: .markers(radius: style.radius))
                .fill(Color.black)

            SuperEllipse(curve: markerCurves.outer,
                         bezierType: .markers(radius: style.radius))
                .fill(Color.black)
        }
    }
}

//MARK:-
struct BaseCurve : View {
    var vertices: [CGPoint]
    let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
    
    var body: some View {
        SuperEllipse(curve: vertices,
                     bezierType: .lineSegments)
        .stroke(Color.white, style: strokeStyle)
    }
}

//MARK:-
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

//MARK:-
struct EnvelopeBounds : View {
    var curves: BoundingCurves
    var style : MarkerStyle
    
    let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
    let color = Color.init(white: 0.15)
    
    var body: some View {
        
        ZStack {
            SuperEllipse(curve: curves.inner,
                         bezierType: .lineSegments)
                .stroke(color, style: strokeStyle)
            
            SuperEllipse(curve: curves.outer,
                         bezierType: .lineSegments)
                .stroke(color, style: strokeStyle)
            
            // MARKERS AT THE INNER-CURVE AND
            // OUTER-CURVE ENDS OF THE NORMALS
            SuperEllipse(curve: curves.inner,
                         bezierType: .markers(radius: style.radius))
                .fill(Color.black)
            
            SuperEllipse(curve: curves.outer,
                         bezierType: .markers(radius: style.radius))
                .fill(Color.black)
        }
    }
}

//MARK:-

struct ZigZags : View {
    var curves: ZigZagCurves
    
    // IMO: a little too busy if we show smoothed variants as well
    static let SHOW_SMOOTHED_CURVES_TOO = false
    
    var body: some View {
        ZStack {
            let lineSegStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
    // ZIG
            SuperEllipse(curve: curves.zig,
                         bezierType: .lineSegments)
                .stroke(Color.red, style: lineSegStyle)

            if ZigZags.SHOW_SMOOTHED_CURVES_TOO {
                SuperEllipse(curve: curves.zig,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .stroke(Color.init(white: 0.6), style: StrokeStyle(lineWidth: 8, dash: [4,2]))
                
                SuperEllipse(curve: curves.zig,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 1.5))
            }
    // ZAG
            SuperEllipse(curve: curves.zag,
                         bezierType: .lineSegments)
                .stroke(Color.green, style: lineSegStyle)
            
            if ZigZags.SHOW_SMOOTHED_CURVES_TOO {
                SuperEllipse(curve: curves.zag,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .stroke(Color.init(white: 0.6), style: StrokeStyle(lineWidth: 8, dash: [4,2]))
                
                SuperEllipse(curve: curves.zag,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 1.5))
            }
        }
    }
}

//MARK:-
struct ZigZag_Markers : View {
    var curves : ZigZagCurves
    var zigStyle : MarkerStyle
    var zagStyle : MarkerStyle
    
    var body : some View {
        
        SuperEllipse(curve: curves.zig,
                     bezierType: .markers(radius: zigStyle.radius + 1))
            .fill(Color.init(white: 0.2))
        
        SuperEllipse(curve: curves.zig,
                     bezierType: .markers(radius: zigStyle.radius))
            .fill(zigStyle.color)
        
//        SuperEllipse(curve: curves.zig,
//                     bezierType: .markers(radius: 1.5))
//            .fill(Color.black)
        
        SuperEllipse(curve: curves.zag,
                     bezierType: .markers(radius: zagStyle.radius + 1))
            .fill(Color.init(white: 0.2))
        
        SuperEllipse(curve: curves.zag,
                     bezierType: .markers(radius: zagStyle.radius))
            .fill(zagStyle.color)
        
//        SuperEllipse(curve: curves.zag,
//                     bezierType: .markers(radius: 1.5))
//            .fill(Color.white)
    }
}

//struct SuperEllipseStacks_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimatingBlobLines(curve: )
//    }
//}
