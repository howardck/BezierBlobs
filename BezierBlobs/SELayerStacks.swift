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
    case offsets
    case baseCurve
//    case zig
//    case zag
}

typealias MarkerStyle = (color: Color, radius: CGFloat)

let r: CGFloat = 15
let markerStyles : [MarkerType : MarkerStyle] = [
    .blob :             (color: .blue, radius: r - 1),
    .vertexOrigin :     (color: .green, radius : r - 1),
    .offsets :   (color: .black, radius: r/2.0 - 1),
    .baseCurve :        (color: .white, radius: r/2.0),
]

//let blueGradient = Gradient(colors: [.blue, .init(white: 0.025)])
//let orangeish = Gradient(colors: [.white, .orange, .red, .white])
//let orangeish = Gradient(colors: [.white, .orange, .red, .black])
let orangeish = Gradient(colors: [.white, .orange, .red, .white, Color.init(white: 0)])
let blueGradient = Gradient(colors: [.blue, .init(white: 0.45)])
let redGradient = Gradient(colors: [.red, .yellow])

//let someG = Gradient(colors: [.blue, .white, .blue])
let highlitRed = Gradient(colors: [.black, .red, .black])

//MARK:- AnimatingBlob_Filled
struct AnimatingBlob_Filled: View {
    
    @EnvironmentObject var layers: SELayersViewModel
    @EnvironmentObject var options: MiscOptionsModel
    @EnvironmentObject var colorScheme : ColorScheme

    var curve: [CGPoint]
    var layerType : LayerType
        
//  another look ...
//  let gradient = LinearGradient(gradient: highlitRed,
    let gradient = LinearGradient(gradient: orangeish,
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
    var body : some View {
        
        if layers.isVisible(layerWithType: .blob_filled) {
            ZStack {
                
                SuperEllipse(curve: curve,
                             smoothed: options.smoothed )
                    .fill(Color.init(white: 0.15))
                    .offset(x: 7, y: 7)
                
                SuperEllipse(curve: curve,
                             smoothed: options.smoothed )
                    .fill(Gray.light)
                    .offset(x: 2, y: 2)
                
                SuperEllipse(curve: curve,
                             smoothed: options.smoothed )
                    .stroke(Color.black,
                            style: StrokeStyle(lineWidth: 0.75, lineJoin: .round))
                    //.offset(x: 0, y: 0)
                
                SuperEllipse(curve: curve,
                             smoothed: options.smoothed )
                    .fill(colorScheme.fill)
            }
        }
    }
}

//MARK:- AnimatingBlob_Stroked
struct AnimatingBlob_Stroked: View {
    var curve: [CGPoint]
    
    @EnvironmentObject var options: MiscOptionsModel
    @EnvironmentObject var colorScheme : ColorScheme
    
    var body : some View {
        
        let isSmoothed = options.smoothed

        ZStack {
            SuperEllipse(curve: curve,
                         smoothed: isSmoothed)
                .stroke(colorScheme.stroke,
                        style: StrokeStyle(lineWidth: 8, lineJoin: .round))
            
            // white highlight
            SuperEllipse(curve: curve,
                         bezierType: .lineSegments,
                         smoothed: isSmoothed)
                .stroke(Color.orange,
                        style: StrokeStyle(lineWidth: 7, lineJoin: .round))
        }
    }
}

//MARK:- AnimatingBlob_Markers
struct AnimatingBlob_Markers : View {
    var curve : [CGPoint]
    var style : MarkerStyle
    
    @EnvironmentObject var colorScheme : ColorScheme
    
    var body : some View {
        
        SuperEllipse(curve: curve,
                     bezierType: .markers(radius: style.radius + 1))
            .fill(Color.black)
                
        SuperEllipse(curve: curve,
                     bezierType: .markers(radius: style.radius))
            .fill(Gray.dark)
            .offset(x: 2.5, y: 2.5)
        
        SuperEllipse(curve: curve,
                     bezierType: .markers(radius: style.radius))
        // NOTA: we now take the fill color from our colorScheme
        // environment object rather than the MarkerStyle arg
            .fill(colorScheme.allVertices)
        
        SuperEllipse(curve: curve,
                     bezierType: .markers(radius: 4))
            .fill(Color.init(white: 0.9))
            .offset(x: -2, y: -2)
    }
}

//MARK:- AnimatingBlob_VertexZeroMarker
struct AnimatingBlob_VertexZeroMarker: View {
    var animatingCurve: [CGPoint]
    var markerStyle : MarkerStyle
    
    @EnvironmentObject var colorScheme : ColorScheme

    var body : some View {
        
        SuperEllipse(curve: animatingCurve,
                     bezierType: .singleMarker(index: 0, radius: markerStyle.radius + 1))
            .fill(Color.black)

        SuperEllipse(curve: animatingCurve,
                     bezierType: .singleMarker(index: 0, radius: markerStyle.radius))
            .fill(colorScheme.vertex0Marker)

        SuperEllipse(curve: animatingCurve,
                     bezierType: .singleMarker(index: 0, radius: 4))
            .fill(Color.white)
            .offset(x: -2, y: -2)
    }
}

//MARK:- NormalsPlusMarkers
struct NormalsPlusMarkers : View {
    
    var normals: [CGPoint]
    var markerCurves: BoundingCurves
    var style : MarkerStyle
    
    var body: some View {
        
        ZStack {
    // NORMALS
            SuperEllipse(curve: normals,
                         bezierType: .normals)
                .stroke(Color.init(white: 1.0),
//                .stroke(Color.orange,
                        style: StrokeStyle(lineWidth: 5, dash: [1, 4]))
            
    // INNER & OUTER MARKERS
            SuperEllipse(curve: markerCurves.inner,
                         bezierType: .markers(radius: style.radius))
                .fill(Color.black)
            SuperEllipse(curve: markerCurves.outer,
                         bezierType: .markers(radius: style.radius))
                .fill(Color.black)
        }
    }
}

//MARK:- BaseCurve_and_Markers
struct BaseCurve_And_Markers : View {
    var curve : [CGPoint]
    var style : MarkerStyle
    
    let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
    
    var body : some View {
        
        ZStack {
            
            SuperEllipse(curve: curve)
                .stroke(Color.white, style: strokeStyle)
            
             SuperEllipse(curve: curve,
                          bezierType: .markers(radius: style.radius + 1))
                .fill(Color.black)
            
            SuperEllipse(curve: curve,
                         bezierType: .markers(radius: style.radius))
                .fill(style.color)
        }
    }
}

//MARK:- EnvelopeBounds
// AKA Curve Offsets
struct OffsetsEnvelope : View {
    var curves: BoundingCurves
    var style : MarkerStyle
    var showInnerOffset: Bool
    var showOuterOffset: Bool
    
    let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
    
    var body: some View {
        
        ZStack {
            if showInnerOffset {
                SuperEllipse(curve: curves.inner)
                    .stroke(style.color, style: strokeStyle)
            }
            if showOuterOffset {
                SuperEllipse(curve: curves.outer)
                    .stroke(style.color, style: strokeStyle)
            }

            if showInnerOffset {
                SuperEllipse(curve: curves.inner,
                             bezierType: .markers(radius: style.radius))
                    .fill(style.color)
            }
            if showOuterOffset {
                SuperEllipse(curve: curves.outer,
                             bezierType: .markers(radius: style.radius))
                    .fill(style.color)
            }
        }
    }
}

//MARK:- ZigZags

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

//MARK:- ZigZag_Markers
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
