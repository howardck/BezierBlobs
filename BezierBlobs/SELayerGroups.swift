//
//  SELayerStacks.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-14.
//

import SwiftUI

enum MarkerType : CaseIterable {
    case blobAllMarkers
    case vertexOrigin
    case offsets
    case baseCurve
}

let r: CGFloat = 11
let markerStyles : [MarkerType : CGFloat] = [
    .blobAllMarkers :   r - 1,
    .vertexOrigin :     r,
    .offsets :          r/2.0 - 1,
    .baseCurve :        r/2.0 - 1,
]

//let blueGradient = Gradient(colors: [.blue, .init(white: 0.025)])
//let orangeish = Gradient(colors: [.white, .orange, .red, .white])
//let orangeish = Gradient(colors: [.white, .orange, .red, .black])
let orangeish = Gradient(colors: [.white, .orange, .red, .white, Color.init(white: 0)])
let blueGradient = Gradient(colors: [.init(white: 0.2), .blue, .init(white: 0.9)])
let redGradient = Gradient(colors: [.red, .yellow])
let highlitRed = Gradient(colors: [.black, .red, .black])

//MARK:- AnimatingBlob_Filled
struct AnimatingBlob_Filled: View {
    
    @EnvironmentObject var layers: SELayersViewModel
    @EnvironmentObject var options: MiscOptionsModel
    @EnvironmentObject var colorScheme : ColorScheme

    var curve: [CGPoint]
    var layerType : LayerType
        
    let gradient = LinearGradient(gradient: blueGradient,
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
    var body : some View {
        
        if layers.isVisible(layerWithType: .blob_filled) {
            ZStack {
                
                SuperEllipse(curve: curve,
                             smoothed: options.smoothed )
                    .fill(Color.init(white: 0.15))
                    .offset(x: 5, y: 5)
                
                SuperEllipse(curve: curve,
                             smoothed: options.smoothed )
                    .fill(Gray.light)
                    .offset(x: 2, y: 2)
                
                SuperEllipse(curve: curve,
                             smoothed: options.smoothed )
                    .stroke(Color.black,
                            style: StrokeStyle(lineWidth: 0.75, lineJoin: .round))
                
                SuperEllipse(curve: curve,
                             smoothed: options.smoothed )
//                    .fill(gradient)
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
                .stroke(Gray.dark,
                        style: StrokeStyle(lineWidth: 6, lineJoin: .round))
            
            SuperEllipse(curve: curve,
                         bezierType: .lineSegments,
                         smoothed: isSmoothed)
                .stroke(colorScheme.stroke,
                        style: StrokeStyle(lineWidth: 5, lineJoin: .round))
        }
    }
}

//MARK:- AnimatingBlob_Markers
struct AnimatingBlob_Markers : View {
    var curve : [CGPoint]
    var markerRadius : CGFloat
    
    @EnvironmentObject var colorScheme : ColorScheme
    
    var body : some View {
        
        SuperEllipse(curve: curve,
                     bezierType: .allMarkers(radius: markerRadius + 1))
            .fill(Color.black)
                
        SuperEllipse(curve: curve,
                     bezierType: .allMarkers(radius: markerRadius))
            .fill(Gray.dark)
            .offset(x: 2.5, y: 2.5)
        
        SuperEllipse(curve: curve,
                     bezierType: .allMarkers(radius: markerRadius))
        // NOTA: we now take the fill color from our colorScheme
        // environment object rather than the MarkerStyle arg
            .fill(colorScheme.allVertices)
        
        SuperEllipse(curve: curve,
                     bezierType: .allMarkers(radius: 3))
            .fill(Color.init(white: 0.9))
            .offset(x: -2, y: -2)
    }
}

//MARK:- AnimatingBlob_EvenNumberedVertexMarkers

struct AnimatingBlob_EvenNumberedVertexMarkers : View {
    var curve : [CGPoint]
    var vertices: Set<Int>
    var markerRadius : CGFloat
    
    @EnvironmentObject var colorScheme : ColorScheme

    var body : some View {
        
        SuperEllipse(curve: curve,
                     bezierType: .someMarkers(indexSet: vertices,
                                             radius: markerRadius + 1))
            .fill(Color.black)
        
        SuperEllipse(curve: curve,
                     bezierType: .someMarkers(indexSet: vertices,
                                              radius: markerRadius))
            .fill(colorScheme.evenNumberedVertices)
        
        SuperEllipse(curve: curve,
                     bezierType: .someMarkers(indexSet: vertices,
                                               radius: 3))
            .fill(Color.white)
            .offset(x: -2, y: -2)
    }
}


//MARK:- AnimatingBlob_VertexZeroMarker
struct AnimatingBlob_VertexZeroMarker: View {
    var animatingCurve: [CGPoint]
    var markerRadius : CGFloat
    
    @EnvironmentObject var colorScheme : ColorScheme

    var body : some View {
        
        SuperEllipse(curve: animatingCurve,
                     bezierType: .singleMarker(index: 0,
                                               radius: markerRadius + 1))
            .fill(Color.black)

        SuperEllipse(curve: animatingCurve,
                     bezierType: .singleMarker(index: 0,
                                               radius: markerRadius))
            .fill(colorScheme.vertex0Marker)

        SuperEllipse(curve: animatingCurve,
                     bezierType: .singleMarker(index: 0,
                                               radius: 4))
            .fill(Color.white)
            .offset(x: -2, y: -2)
    }
}

//MARK:- NormalsPlusMarkers
struct NormalsPlusMarkers : View {
    
    var normals: [CGPoint]
    var markerCurves: BoundingCurves
    var markerRadius : CGFloat
    
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
                         bezierType: .allMarkers(radius: markerRadius))
                .fill(Color.black)
            SuperEllipse(curve: markerCurves.outer,
                         bezierType: .allMarkers(radius: markerRadius))
                .fill(Color.black)
        }
    }
}

//MARK:- BaseCurve_and_Markers
struct BaseCurve_And_Markers : View {
    var curve : [CGPoint]
    var markerRadius : CGFloat
    
    let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
    
    @EnvironmentObject var colorScheme : ColorScheme
    
    var body : some View {
        
        ZStack {
            
            SuperEllipse(curve: curve)
                .stroke(Color.white, style: strokeStyle)
            
             SuperEllipse(curve: curve,
                          bezierType: .allMarkers(radius: markerRadius + 1))
                .fill(colorScheme.baseCurveMarkers)
            
            SuperEllipse(curve: curve,
                         bezierType: .allMarkers(radius: markerRadius))
                .fill(colorScheme.baseCurveMarkers)
        }
    }
}

//MARK:- EnvelopeBounds
// AKA Curve Offsets
struct OffsetCurves : View {
    var curves: BoundingCurves
    var markerRadius : CGFloat
    var showOffsets: (inner: Bool, outer: Bool)
    
    let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
    
    @EnvironmentObject var colorScheme : ColorScheme

    var body: some View {
        
        ZStack {
            
            if showOffsets.inner == true {
                
                SuperEllipse(curve: curves.inner,
                             bezierType: .allMarkers(radius: markerRadius))
                    .fill(colorScheme.offsetMarkers)
                
                SuperEllipse(curve: curves.inner)
                    .stroke(colorScheme.offsetMarkers, style: strokeStyle)
            }
            
            if showOffsets.outer == true {
                
                SuperEllipse(curve: curves.outer,
                             bezierType: .allMarkers(radius: markerRadius))
                    .fill(colorScheme.offsetMarkers)
                
                SuperEllipse(curve: curves.outer)
                    .stroke(colorScheme.offsetMarkers, style: strokeStyle)
            }
        }
    }
}

//struct SuperEllipseStacks_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimatingBlobLines(curve: )
//    }
//}
