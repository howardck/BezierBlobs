//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

enum PageType : String {
    case circle = "CIRCLE"
    case superEllipse = "SUPER-ELLIPSE BLOB"
    case sweptWing = "SWEPT WING"
    case killerMoth = "MUTANT MOTH"
}
typealias PageDescription = (numPoints: Int,
                             n: Double,
                             offsets: (in: CGFloat, out: CGFloat),
                             forceEqualAxes: Bool)

struct PageView: View {
        
     static let descriptions : [PageDescription] =
        [
            (numPoints: 4, n: 2, offsets: (in: -0.2, out: 0.35), forceEqualAxes: true),
            (numPoints: 22, n: 4.0, offsets: (in: -0.2, out: 0.35), false),
            (numPoints: 6, n: 3, offsets: (in: -0.55, out: 0.35), false),
            (numPoints: 24, n: 1.0, offsets: (in: 0.1, out: 0.5), false)
        ]
    
    @ObservedObject var model = Model()
 
    let description: PageDescription
    let size: CGSize
    
    var pageType: PageType

    //MARK: - SHOW & HIDE THINGS
    
    @State var isLayerSelectionListVisible = false
    
    // "isVisible = true" entries below indicate which layers are
    // VISIBLE BY DEFAULT at startup
    @State var superEllipseLayers : [SuperEllipseLayer] =
    [
        .init(type: .animatingBlob, id: .animatingBlob,
              animationType: .animating, name: "blob"),
        .init(type: .animatingBlob_markers, id: .animatingBlob_markers,
              animationType: .animating, name: "blob -- markers", isVisible: true),
        .init(type: .animatingBlob_originMarkers, id: .animatingBlob_originMarkers,
              animationType: .animating, name: "blob -- vertex 0 marker", isVisible: true),
        
        .init(type: .baseCurve, id: .baseCurve,
              animationType: .ancillary, name: "base curve", isVisible: true),
        .init(type: .baseCurve_markers, id: .baseCurve_markers,
              animationType : .ancillary, name: "base curve -- markers", isVisible: true),
        
        .init(type: .normals, id: .normals,
              animationType : .ancillary, name: "normals", isVisible: true),
        
        .init(type: .envelopeBounds, id: .envelopeBounds, animationType: .ancillary,
              name: "inner-to-outer-curve envelope"),
        .init(type: .zigZags, id: .zigZags,
              animationType : .ancillary, name: "zig-zag curves"),
        .init(type: .zigZag_markers, id: .zigZag_markers,
              animationType : .ancillary, name: "zig-zag curves -- markers")
    ]
    
    //MARK:-
    init(pageType: PageType, description: PageDescription, size: CGSize) {

//        print("PageView.init(PageType.------------  \(pageType.rawValue)  -------------)")
        
        self.pageType = pageType
        self.description = description
        
        self.size = CGSize(width: size.width * PlatformSpecifics.IPAD.w,
                           height: size.height * PlatformSpecifics.IPAD.h)
        
        model.calculateSuperEllipseCurves(for: pageType,
                                          pageDescription: description,
                                          axes: (a: Double(self.size.width/2),
                                                 b: Double(self.size.height/2)))
     }
    
    //MARK:-
    var body: some View {
    
        ZStack {
            
            pageGradientBackground()

            if superEllipseLayers[LayerType.animatingBlob.rawValue].isVisible {
                AnimatingBlob(curve: model.blobCurve,
                              stroked: true,
                              filled: true)
            }
            if superEllipseLayers[LayerType.zigZags.rawValue].isVisible {
                ZigZags(curves: model.zigZagCurves)
            }
            
            // combine lines and markers to avoid the 10-view limit
            /*
                NOTA: trying a newish version in which the normal END MARKERS
                are now being drawn by the EnvelopeBounds() routine below.
             */
            if superEllipseLayers[LayerType.normals.rawValue].isVisible {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   style: markerStyles[.envelopeBounds]!)
            }
            
            if superEllipseLayers[LayerType.baseCurve.rawValue].isVisible {
                BaseCurve(vertices: model.baseCurve.vertices)
            }
            
            // see above. EnvelopeBounds() now draw both the bounds + the inner
            // and outer markers, priorly the remit of NormalsPlusMarkers
            if superEllipseLayers[LayerType.envelopeBounds.rawValue].isVisible {
                EnvelopeBounds(curves: model.boundingCurves,
                               style: markerStyles[.envelopeBounds]!)
            }
            
            if superEllipseLayers[LayerType.zigZag_markers.rawValue].isVisible {
                ZigZag_Markers(curves: model.zigZagCurves,
                               zigStyle : markerStyles[.zig]!,
                               zagStyle : markerStyles[.zag]!)
            }
            if superEllipseLayers[LayerType.animatingBlob_markers.rawValue].isVisible {
                AnimatingBlob_Markers(curve: model.blobCurve,
                                      style: markerStyles[.blob]!)
            }
            if superEllipseLayers[LayerType.baseCurve_markers.rawValue].isVisible {
                BaseCurve_Markers(curve: model.baseCurve.vertices,
                                  style: markerStyles[.baseCurve]!)
            }
            if superEllipseLayers[LayerType.animatingBlob_originMarkers.rawValue].isVisible {
                AnimatingBlob_VertexOriginMarker(animatingCurve: model.blobCurve,
                                              markerStyle: markerStyles[.vertexOrigin]!)
            }
        }
        .measure(color: .yellow)
        .onAppear()
        {
            print("PageView.onAppear(PageType.\(pageType.rawValue))" )
        }
        // NOTA: check for 2 taps BEFORE checking for 1 tap.
        // NOTA: this slows down start of the animation BRIEFLY
        // while the system waits to determine a 2-tap DIDN'T happen.
        
        .onTapGesture(count: 2) {
            withAnimation(Animation.easeInOut(duration: 0.6))
            {
                model.returnToInitialConfiguration()
            }
        }
        .onTapGesture(count: 1)
        {
            withAnimation(Animation.easeInOut(duration: 1.6))
            {
                model.animateToNextZigZagPhase()
            }
            
            if isLayerSelectionListVisible {
                isLayerSelectionListVisible = false
            }
        }
        
        // COMING UP : initially placed in the lower-left ...
        /*
         HighlightedPencilButton(name: pencilInSquare,
                                 faceColor: .blue,
                                 edgeColor: .pink)
         */
        
//        .overlay(
//            VStack {
//                Spacer()
//                HStack {
//                    HighlightedPencilButton(name: pencilWithEllipsis,
//                                            faceColor: .blue,
//                                            edgeColor: .red)
//                        .scaleEffect(1.25)
//                        .padding(60)
//                    Spacer()
//                }
//            }
//        )
        
        // LayerStack Button to lower-right corner. is there a cleaner way ... ??
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if isLayerSelectionListVisible {
                        
                        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                        // NOTA: SIZE IS IPAD-ONLY RIGHT NOW
                        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                        
                        let s = CGSize(width: 320, height: 500)
                        
                        ZStack {
                            LayerSelectionDialog(listItems: $superEllipseLayers)
                                .frame(width: s.width, height: s.height)
                                .padding(70)
                            bezelFrame(color: .red, size: s)
                        }
                    }
                    else {
                        VStack {
                            HighlightedPencilButton(name: pencilInSquare,
                                                    faceColor: .blue,
                                                    edgeColor: .orange)
                            Spacer()
                                .frame(width: 70, height: 20)
                            
                            HighlightedLayerStackButton(faceColor: .blue,
                                                        edgeColor: .orange)
                                .onTapGesture {
                                    print("SquareStackSymbol tapped")
                                    isLayerSelectionListVisible.toggle()
                                }
                        }
                        .scaleEffect(1.4)
                        .padding(70)
                    }
                }
            }
        )
        .overlay(pageMetricsTextDescription())
    }
    
    private func bezelFrame(color: Color, size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .stroke(color, lineWidth: 8)
                .frame(width: size.width, height: size.height)
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white, lineWidth: 1.25)
                .frame(width: size.width, height: size.height)
        }
    }

    //MARK:-
    private func pageGradientBackground() -> some View {
        let colors : [Color] = [.init(white: 0.65), .init(white: 0.3)]
        return LinearGradient(gradient: Gradient(colors: colors),
                              startPoint: .topLeading,
                              endPoint: .bottom)
    }
    
    func pageMetricsTextDescription() -> some View {
        VStack(spacing: 10) {
            DropShadowedText(text: "numPoints: \(description.numPoints)",
                             foreColor: .white,
                             backColor: .init(white: 0.2))
            DropShadowedText(text: "n: \(description.n.format(fspec: "3.1"))",
                             foreColor: .white,
                             backColor: .init(white: 0.2))
        }
   }
}

struct DropShadowedText : View {
    var text: String
    var foreColor: Color
    var backColor: Color
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Text(text)
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(backColor)
                    .offset(x: 2, y: 2)
                Text(text)
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(foreColor)
            }
        }
    }
}

//MARK:-

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pageType: PageType.circle, description: PageView.descriptions[0], size: CGSize(width: 650, height: 550))
    }
}
