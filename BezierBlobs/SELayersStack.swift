//
//  SELayersStack.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-11.
//

import SwiftUI

enum MarkerType {
    case blobAllMarkers
    case vertexOrigin
    case orbitingVertices
    case offsets
    case normals
    case baseCurve
}
let markerSize : [MarkerType : CGFloat] = [
    .blobAllMarkers :   SELayersStack.r ,
    .vertexOrigin :     SELayersStack.r ,
    .orbitingVertices : SELayersStack.r,
    .offsets :          SELayersStack.r/2.0 - 0.25,
    .normals:           SELayersStack.r/2.0 - 0.5,
    .baseCurve :        SELayersStack.r/2.0 - 0.5 ,
]

// all seem reasonable. may require a different stroke color tho...
struct FILL_GRADIENTS {
    static let orangeish = Gradient(colors: [.white, .orange, .red, .white, Color.init(white: 0)])
    static let darkBlueish = Gradient(colors:  [.blue, .init(white: 0.07)])
    static let lightBlueish : Gradient = Gradient(colors: [.init(white: 0.2), .blue, .init(white: 0.9)])
    static let yellowish = Gradient(colors: [.red, .yellow])
    static let highlitRed = Gradient(colors: [.black, .red, .black])
}

struct SELayersStack: View {
    
    static let shadowOffset : CGFloat = 3.25
    static var r: CGFloat = 8
    static let specularHiliteSize : CGFloat = 3
    
    @ObservedObject var model: Model
    
    @EnvironmentObject var options: MiscOptionsModel
    @EnvironmentObject var layers : SELayersModel
    @EnvironmentObject var colorScheme : ColorScheme

    //MARK: -
    var body: some View {
        
        let evenMarkersAreVisible = layers.isVisible(layerType: .animatingBlobEvenMarkers)
        
        if layers.isVisible(layerType: .animatingBlobFilled) {
            
            animatingBlob_filled(blobCurve: model.blobCurve,
                                gradient: FILL_GRADIENTS.darkBlueish)
        }
        
        if layers.isVisible(layerType: .offsetCurves) {
            
            innerAndOuter(offsetCurves: model.offsetCurves,
                          markerRadius: markerSize[.offsets]!,
                          showOffsets: (inner: false, outer: true))
        }
        
        if layers.isVisible(layerType: .offsetCurves) {
            
            innerAndOuter(offsetCurves: model.offsetCurves,
                          markerRadius: markerSize[.offsets]!,
                          showOffsets: (inner: true, outer: false))
        }
        
        if layers.isVisible(layerType: .normals) {
            
            normalsWithEndMarkers(normals: model.normalsCurve,
                                  markerCurves: model.offsetCurves,
                                  markerRadius: markerSize[.normals]!)
        }
        
        if layers.isVisible(layerType: .baseCurveWithMarkers) {
            
            baseCurveWithMarkers(curve: model.baseCurve.map{ $0.vertex },
                                 markerRadius: markerSize[.baseCurve]!)
        }
        
        if layers.isVisible(layerType: .animatingBlobStroked) {
            
            animatingBlob_stroked(blobCurve: model.blobCurve)
                .shadow(radius: 4, x: Self.shadowOffset, y: Self.shadowOffset)
        }
        
        // NOTA: we need the Group container else too many subviews
        // ("The compiler is unable to type-check this expression in reasonable time;
        // try breaking up the expression into distinct sub-expressions")
        Group {
            if layers.isVisible(layerType: .animatingOrbitalMarkers) {
                
                // two trains of colored dots, one rotating against
                // and inside the orbit of the other.
                orbitingVertices_someMarkers(orbitalCurve: model.orbitalCurves.inner,
                                             markerRadius: markerSize[.orbitingVertices]!,
                                             innerColor: colorScheme.orbitalVertexInner)
                
                orbitingVertices_someMarkers(orbitalCurve: model.orbitalCurves.outer,
                                             markerRadius: markerSize[.orbitingVertices]!,
                                             innerColor: colorScheme.orbitalVertexOuter)
            }
            
            if layers.isVisible(layerType: .animatingBlobOddMarkers) {
                
                animatingBlob_oddNumberedVertexMarkers(blobCurve: model.blobCurve,
                                                       markerRadius: markerSize[.blobAllMarkers]!)
            }
            
            if evenMarkersAreVisible {
           // if layers.isVisible(layerType: .animatingBlobEvenMarkers) {
                
                animatingBlob_evenNumberedVertexMarkers(blobCurve: model.blobCurve,
                                                        markerRadius:  markerSize[.blobAllMarkers]!)
            }
            
            if layers.isVisible(layerType: .animatingBlobOriginMarker) {
                
                let drawShadow = !layers.isVisible(layerType: .animatingBlobEvenMarkers)
                animatingBlob_vertexZeroMarker(blobCurve: model.blobCurve,
                                               markerRadius: markerSize[.vertexOrigin]!,
                                               innerColor: .black,
                                               drawShadow: drawShadow)
            }
        }
    }

    
    //MARK: -
    func animatingBlob_filled(blobCurve: [CGPoint],
                             gradient: Gradient) -> some View {
        let fillStyle = LinearGradient(gradient: gradient,
                                       startPoint: .bottomTrailing,
                                       endPoint: .topLeading)
        return AnimatingSuperEllipse(curve: blobCurve,
                              smoothed: options.smoothed)
            .fill(fillStyle)
    }
    
    //MARK: -
    func innerAndOuter(offsetCurves: OffsetCurves,
                       markerRadius : CGFloat,
                       showOffsets: (inner: Bool, outer: Bool)) -> some View {
        let strokeStyle = StrokeStyle(lineWidth: 1, dash: [3,2])
        
        return ZStack {
            if showOffsets.inner {
                SuperEllipse(curve: offsetCurves.inner,
                             bezierType: .allMarkers(radius: markerRadius))
                    .fill(colorScheme.offsetMarkers)
                SuperEllipse(curve: offsetCurves.inner)
                    .stroke(colorScheme.offsetMarkers, style: strokeStyle)
            }
            if showOffsets.outer {
                SuperEllipse(curve: offsetCurves.outer,
                             bezierType: .allMarkers(radius: markerRadius))
                    .fill(colorScheme.offsetMarkers)
                SuperEllipse(curve: offsetCurves.outer)
                    .stroke(colorScheme.offsetMarkers, style: strokeStyle)
            }
        }
    }
    
    func normalsWithEndMarkers(normals: [CGPoint],
                               markerCurves: OffsetCurves,
                               markerRadius: CGFloat) -> some View {
        let strokeStyle = StrokeStyle(lineWidth: 5.5, dash: [0.75, 3])
        
        return ZStack {

            SuperEllipse(curve: normals, bezierType: .normals)
                .stroke(Color.init(white: 1.0), style: strokeStyle)
            
            SuperEllipse(curve: markerCurves.inner, bezierType: .allMarkers(radius: markerRadius + 4.0))
                .fill(Color.white)
            SuperEllipse(curve: markerCurves.inner, bezierType: .allMarkers(radius: markerRadius + 2))
                .fill(Color.black)
            
            SuperEllipse(curve: markerCurves.outer, bezierType: .allMarkers(radius: markerRadius + 4.0))
                .fill(Color.white)
            SuperEllipse(curve: markerCurves.outer, bezierType: .allMarkers(radius: markerRadius + 2.0))
                .fill(Color.black)
        }
    }
    
    func baseCurveWithMarkers(curve: [CGPoint],
                              markerRadius: CGFloat) -> some View {
        let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [3,2])
        
        return ZStack {
            SuperEllipse(curve: curve)
                .stroke(Color.white, style: strokeStyle)
            SuperEllipse(curve: curve,
                         bezierType: .allMarkers(radius: markerRadius + 5.0))
                .fill(.black)
            SuperEllipse(curve: curve,
                         bezierType: .allMarkers(radius: markerRadius + 3.0))
                .fill(colorScheme.baseCurveMarkers)
        }
    }
    
    //MARK: -
    func animatingBlob_stroked(blobCurve: [CGPoint]) -> some View {

        ZStack {
            AnimatingSuperEllipse(curve: blobCurve,
                                  smoothed: options.smoothed)
                .stroke(Color.init(white: 1),
                        style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                .offset(x: -0.75, y: -0.75)

            AnimatingSuperEllipse(curve: blobCurve,
                                  bezierType: .lineSegments,
                                  smoothed: options.smoothed)
                .stroke(colorScheme.stroke,
                        style: StrokeStyle(lineWidth: 3, lineJoin: .round))
        }
    }
    
    // no longer using this; leave in case someone else wants to
//    func animatingBlob_allVertexMarkers(blobCurve: [CGPoint],
//                                        markerRadius: CGFloat) -> some View {
//        ZStack {
//        // black outline
//            AnimatingSuperEllipse(curve: blobCurve,
//                                  bezierType: .allMarkers(radius: markerRadius + 1.0))
//                .fill(Color.black)
//        // main color
//            AnimatingSuperEllipse(curve: blobCurve,
//                                  bezierType: .allMarkers(radius: markerRadius))
//                .fill(colorScheme.allVertices)
//        // specular highlight
//            AnimatingSuperEllipse(curve: blobCurve,
//                                  bezierType: .allMarkers(radius: Self.specularHiliteSize))
//                .fill(Color.init(white: 0.9))
//                .offset(x: -2, y: -2)
//        }
//        .shadow(radius: 3, x: Self.shadowSize, y: Self.shadowSize)
//    }
    
    func animatingBlob_oddNumberedVertexMarkers(blobCurve: [CGPoint],
                                                markerRadius: CGFloat) -> some View {
        ZStack {
        // black outline
            AnimatingSuperEllipse(curve: blobCurve,
                                  bezierType: .oddNumberedMarkers(radius: markerRadius + 1.0))
                .fill(Color.black)
        // main color
            AnimatingSuperEllipse(curve: blobCurve,
                                  bezierType: .oddNumberedMarkers(radius: markerRadius))
                .fill(colorScheme.oddNumberedVertices)
        // specular highlight
            AnimatingSuperEllipse(curve: blobCurve,
                                  bezierType: .oddNumberedMarkers(radius: Self.specularHiliteSize))
                .fill(Color.white)
                .offset(x: -2, y: -2)
        }
        .shadow(radius: 3, x: Self.shadowOffset, y: Self.shadowOffset)
    }
    
    func animatingBlob_evenNumberedVertexMarkers(blobCurve: [CGPoint],
                                                 markerRadius: CGFloat) -> some View {
        ZStack {
        // black outline
            AnimatingSuperEllipse(curve: blobCurve,
                                  bezierType: .evenNumberedMarkers(radius: markerRadius + 1.0))
                .fill(Color.black)
        // main color
            AnimatingSuperEllipse(curve: blobCurve,
                                  bezierType: .evenNumberedMarkers(radius: markerRadius))
                .fill(colorScheme.evenNumberedVertices)
        // specular highlight
            AnimatingSuperEllipse(curve: blobCurve,
                                  bezierType: .evenNumberedMarkers(radius: Self.specularHiliteSize))
                .fill(Color.white)
                .offset(x: -2, y: -2)
        }
        // NOTA (TBI): show the shadow IFF we're NOT showing evenNumberedVertices
        // if we do both sets of v's and they BOTH shadow, we get a double-heavy shadow
        // ============================================================================
        .shadow(radius: 3, x: Self.shadowOffset, y: Self.shadowOffset)
    }
    
    func animatingBlob_vertexZeroMarker(blobCurve: [CGPoint],
                                        markerRadius: CGFloat,
                                        innerColor: Color,
                                        drawShadow: Bool) -> some View {
        ZStack {
            // black outline
                AnimatingSuperEllipse(curve: blobCurve,
                                      bezierType: .singleMarker(index: 0, radius: markerRadius + 0.5))
                .fill(Gray.dark) // shadow's a bit too heavy if we use black
            // main color`
                AnimatingSuperEllipse(curve: blobCurve,
                                      bezierType: .singleMarker(index: 0, radius: markerRadius))
                    .fill(colorScheme.vertex0Marker)
            // specular highlight
                AnimatingSuperEllipse(curve: blobCurve,
                                      bezierType: .singleMarker(index: 0, radius: Self.specularHiliteSize))
                    .fill(Color.white)
                    .offset(x: -2, y: -2)
        }
        // a very minor difference: if we've already drawn an even-marker
        // underneath, we don't want to double-draw the shadow
        .shadow(color: drawShadow ?
                        Color(.sRGBLinear, white: 0, opacity: 0.33) :
                        Color(.sRGBLinear, white: 0, opacity: 0),
                radius: 3,
                x: Self.shadowOffset, y: Self.shadowOffset)
    }
    
    //MARK: -
    func orbitingVertices_someMarkers(orbitalCurve: [CGPoint],
                                      markerRadius : CGFloat,
                                      innerColor: Color) -> some View {
        // NOTA: you can get various effects by changing the
        // bezierType: parameter to animate other combinations of vertices
        ZStack {
        // black outline
            AnimatingSuperEllipse(curve: orbitalCurve,
                                  bezierType: .allMarkers(radius: markerRadius + 1.5))
                .fill(.black)
        // outer rim
            AnimatingSuperEllipse(curve: orbitalCurve,
                                  bezierType: .allMarkers(radius: markerRadius + 1.25))
                .fill(.white)
        // inside color
            AnimatingSuperEllipse(curve: orbitalCurve,
                                  bezierType: .allMarkers(radius: 6))
                .fill(innerColor)
        }
        .shadow(radius: 3, x: Self.shadowOffset, y: Self.shadowOffset)
    }
    
    // used in a prior incarnation of the app. leave for future reference ...
    
    func orbitingVertices_singleMarker(orbitalCurve: [CGPoint],
                                       markerRadius: CGFloat,
                                       mainColor: Color,
                                       markerIndex: Int) -> some View {
        
                ZStack {
            // black outline
                    AnimatingSuperEllipse(curve: orbitalCurve,
                                          bezierType: .singleMarker(index: markerIndex,
                                                                    radius: markerRadius + 1.5))
                        .fill(.black)
            // outer rim
                    AnimatingSuperEllipse(curve: orbitalCurve,
                                          bezierType: .singleMarker(index: markerIndex,
                                                                    radius: markerRadius + 1.25))
                        .fill(.white)
            // inside color
                    AnimatingSuperEllipse(curve: orbitalCurve,
                                          bezierType: .singleMarker(index: markerIndex,
                                                                    radius: 6))
                        .fill(mainColor)
                }
                .shadow(radius: 3, x: Self.shadowOffset, y: Self.shadowOffset)
    }
}

//MARK: -
struct SELayersVisibilityToggles_Previews: PreviewProvider {
    static var previews: some View {
        
        SELayersStack(model: Model())
    }
}
