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
    case deltaWing = "DELTA WING"
    case killerMoth = "MUTANT MOTH"
}
typealias PageDescription = (numPoints: Int,
                             n: Double,
                             offsets: (in: CGFloat, out: CGFloat),
                             forceEqualAxes: Bool)

struct PageView: View {
        
     static let descriptions : [PageDescription] =
        [
            (numPoints: 8, n: 2, offsets: (in: -0.2, out: 0.35), forceEqualAxes: true),
            (numPoints: 22, n: 4.0, offsets: (in: -0.2, out: 0.35), false),
            (numPoints: 6, n: 3, offsets: (in: -0.55, out: 0.35), false),
            (numPoints: 24, n: 1.0, offsets: (in: 0.1, out: 0.5), false)
        ]
    
    @ObservedObject var model = Model()
 
    let description: PageDescription
    let size: CGSize
    
    var pageType: PageType
    
    @State var layerSelectionListIsVisible = false
    
    //MARK:- [SuperEllipseLayers] array initialization
    @State var superEllipseLayers : [SuperEllipseLayer] =
    [

 
        .init(type: .blob, section: .animating, name: "blob"),
        .init(type: .blob_markers, section: .animating, name: "blob -- markers"),
        .init(type: .blob_originMarkers, section: .animating, name: "blob -- vertex 0 marker",
              visible: true),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        .init(type: .baseCurve, section: .support, name: "base curve",
              visible: true),
        .init(type: .baseCurve_markers, section : .support, name: "base curve -- markers",
              visible: true),
        .init(type: .normals, section : .support, name: "normals", visible: true),
        .init(type: .envelopeBounds, section: .support,  name: "inner-to-outer envelope"),
        .init(type: .zigZagsPlusMarkers, section : .support, name: "zig-zags + markers"),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        .init(type: .showAll, section: .control, name: "show all layers"),
        .init(type: .hideAll, section: .control, name: "hide all layers")
    ]
    
    //MARK:-
    init(pageType: PageType, description: PageDescription, size: CGSize) {

        self.pageType = pageType
        self.description = description
        self.size = CGSize(width: size.width * PlatformSpecifics.IPAD.w,
                           height: size.height * PlatformSpecifics.IPAD.h)
        
        model.calculateSuperEllipseCurves(for: pageType,
                                          pageDescription: description,
                                          axes: (a: Double(self.size.width/2),
                                                 b: Double(self.size.height/2)))
     }
    
    var body: some View {
    
        ZStack {
            
            pageGradientBackground()
            
        //MARK: - show & hide SuperEllipse layers according to
        //MARK: the user's selections in the layer selection list

    // ANIMATING BLOB
            if superEllipseLayers[LayerType.blob.rawValue].visible {
                AnimatingBlob(curve: model.blobCurve,
                              stroked: true,
                              filled: true)
            }
    // ZIG-ZAGS -- CURVES SECTION
            if superEllipseLayers[LayerType.zigZagsPlusMarkers.rawValue].visible {
                ZigZags(curves: model.zigZagCurves)
            }
            
            // combine lines and markers to avoid the 10-view limit
    // NORMALS + MARKERS
            if superEllipseLayers[LayerType.normals.rawValue].visible {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   style: markerStyles[.envelopeBounds]!)
            }
    // BASE CURVE
            if superEllipseLayers[LayerType.baseCurve.rawValue].visible {
                BaseCurve(vertices: model.baseCurve.vertices)
            }
            
            // see above. EnvelopeBounds() now draws both the bounds + the inner
            // & outer markers, priorly the remit of NormalsPlusMarkers
    // ENVELOPE BOUNDS
            if superEllipseLayers[LayerType.envelopeBounds.rawValue].visible {
                EnvelopeBounds(curves: model.boundingCurves,
                               style: markerStyles[.envelopeBounds]!)
            }
    // ZIG-ZAG -- MARKERS SECTION
            if superEllipseLayers[LayerType.zigZagsPlusMarkers.rawValue].visible {
                ZigZag_Markers(curves: model.zigZagCurves,
                               zigStyle : markerStyles[.zig]!,
                               zagStyle : markerStyles[.zag]!)
            }
    // ANIMATING BLOB MARKERS
            if superEllipseLayers[LayerType.blob_markers.rawValue].visible {
                AnimatingBlob_Markers(curve: model.blobCurve,
                                      style: markerStyles[.blob]!)
            }
    // BASE CURVE MARKERS
            if superEllipseLayers[LayerType.baseCurve_markers.rawValue].visible {
                BaseCurve_Markers(curve: model.baseCurve.vertices,
                                  style: markerStyles[.baseCurve]!)
            }
    // VERTEX[0] MARKER
            if superEllipseLayers[LayerType.blob_originMarkers.rawValue].visible {
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
        // this slows down the start of the animation slightly
        
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
            
            if layerSelectionListIsVisible {
                layerSelectionListIsVisible.toggle()
            }
        }
        
        // LayerStack Button to lower-right corner.
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if layerSelectionListIsVisible {
                        
                        // NB: padding might change w/ iPhone sizing ... (?)
                        
                        let s = CGSize(width: 280, height: 580)
                        ZStack {
                            LayerSelectionList(listItems: $superEllipseLayers)
                                .frame(width: s.width, height: s.height)
                                .padding(70)
                            bezelFrame(color: .orange, size: s)
                        }
                    }
                    else {
                        VStack {
                            HighlightedPencilButton(name: pencilInSquare,
                                                    faceColor: .blue,
                                                    edgeColor: .orange)
                            Spacer()
                                .frame(width: 70, height: 25)
                            
                            HighlightedLayerStackButton(faceColor: .blue,
                                                        edgeColor: .orange)
                                .onTapGesture {
                                    print("SquareStackSymbol tapped")
                                    layerSelectionListIsVisible.toggle()
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
    
    // a little bit of eye candy
    //MARK:-
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

//MARK:-
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
