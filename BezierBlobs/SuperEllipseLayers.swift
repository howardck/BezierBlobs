//
//  SELayerStacks.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-14.
//

import SwiftUI

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
    .vertexOrigin :     (color: .green, radius : r + 2),
    .envelopeBounds :   (color: .black, radius: 8),
    .baseCurve :        (color: .white, radius: r + 2),
    .zig :              (color: .red, radius : r - 3),
    .zag :              (color: .yellow, radius: r - 3)
]

//let blueGradient = Gradient(colors: [.blue, .init(white: 0.025)])
let orangeish = Gradient(colors: [.red, .orange, .black])
let blueGradient = Gradient(colors: [.blue, .init(white: 0.45)])
let redGradient = Gradient(colors: [.red, .yellow])

//let someG = Gradient(colors: [.blue, .white, .blue])
let highlitRed = Gradient(colors: [.black, .red, .black
])


struct AnimatingBlob_Filled: View {
    
    // @@@@@@@@@@@@  EXPLORING  @@@@@@@@@@@@@@
    @EnvironmentObject var layersModel: Layers
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    var curve: [CGPoint]
    var layerType : LayerType
    @Binding var smoothed : Bool
    
    let gradient = LinearGradient(gradient: highlitRed,
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
    var body : some View {
        
        if layersModel.isVisible(layerWithType: .blob_filled) {
            
            ZStack {
                SuperEllipse(curve: curve,
                             smoothed: smoothed)
                    .fill(gradient)
                
                SuperEllipse(curve: curve,
                             smoothed: smoothed)
                    .stroke(Color.init(white: 0.35), lineWidth: 1)
            }
        }
    }
}

//MARK:-
struct AnimatingBlob_Stroked: View {
    var curve: [CGPoint]
    
    @Binding var smoothed : Bool
    
    let gradient = LinearGradient(gradient: blueGradient,
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing)
    var body : some View {
        //let smoothed = false
        ZStack {
            SuperEllipse(curve: curve,
                         smoothed: smoothed)
               .stroke(Color.init(white: 0.15), lineWidth: 11)
//                .stroke(Color.blue, lineWidth: 10)
//                .stroke(Color.green, lineWidth: 10)
            
            SuperEllipse(curve: curve,
                         bezierType: .lineSegments,
                         smoothed: smoothed)
                .stroke(Color.white, lineWidth: 0.75)
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

struct AnimatingBlob_VertexZeroMarker: View {
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
                         bezierType: .normals)
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
        SuperEllipse(curve: vertices)
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
// AKA Curve Offsets
struct EnvelopeBounds : View {
    var curves: BoundingCurves
    var style : MarkerStyle
    
    let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
    let color = Color.init(white: 0.15)
    
    var body: some View {
        
        ZStack {
            SuperEllipse(curve: curves.inner)
                .stroke(color, style: strokeStyle)
            
            SuperEllipse(curve: curves.outer)
                .stroke(color, style: strokeStyle)
            
            // markers at the inner and outer ends of our normals.
            // NOTE these are duplicated in the struct NormalsPlusMarkers{ }
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
    
    // an interesting effect that IMO makes things just a bit too
    // busy looking; it's here just in case you think it's worth a look.
    
    static let SHOW_SMOOTHED_CURVES_TOO = false
    
    var body: some View {
        ZStack {
            
    // ZIG
            SuperEllipse(curve: curves.zig)
                .stroke(Color.red, style: StrokeStyle(lineWidth: 2.0, dash: [4,3]))

            if ZigZags.SHOW_SMOOTHED_CURVES_TOO
            {
                SuperEllipse(curve: curves.zig,
                             smoothed: true)
                    .stroke(Color.init(white: 0.6), style: StrokeStyle(lineWidth: 8, dash: [4,2]))
                
                SuperEllipse(curve: curves.zig,
                             smoothed: true)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 1.5))
            }
    // ZAG
            SuperEllipse(curve: curves.zag)
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 1.5, dash: [4,3]))
            
            if ZigZags.SHOW_SMOOTHED_CURVES_TOO
            {
                SuperEllipse(curve: curves.zag,
                             smoothed: true)
                    .stroke(Color.init(white: 0.6), style: StrokeStyle(lineWidth: 8, dash: [4,2]))
                
                SuperEllipse(curve: curves.zag,
                             smoothed: true)
                    .stroke(Color.yellow, style: StrokeStyle(lineWidth: 1.5))
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
