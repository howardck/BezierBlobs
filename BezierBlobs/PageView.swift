//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI


enum LayerType : Int {
    case blob_stroked
    case blob_filled
    case blob_vertex_0_Marker
    case blob_markers
    case zigZagsPlusMarkers
    case baseCurve
    case baseCurve_markers
    case normals
    case envelopeBounds
    case showAll
    case hideAll
}

enum PageType : String {
    case circle = "ALMOST CIRCLE"
    case superEllipse = "SUPER-ELLIPSE BLOB"
    case deltaWing = "DELTA WING"
    case killerMoth = "MUTANT MOTH"
}

typealias PageDescription = (numPoints: Int,
                             n: Double,
                             offsets: (in: CGFloat, out: CGFloat),
                             perturbLimits: PerturbationLimits,
                             forceEqualAxes: Bool)
struct PageView: View {
        
     static let descriptions : [PageDescription] =
        [
            (numPoints: 12, n: 2.5,
             offsets: (in: -0.25, out: 0.2), perturbLimits: (inner: 0.7, outer: 0.7), forceEqualAxes: true),
//             offsets: (in: -0.25, out: 0.35), perturbLimits: (inner: 0.5, outer: 0.6), forceEqualAxes: true),

            (numPoints: 22, n: 3.5,
             offsets: (in: -0.2, out: 0.35), perturbLimits: (inner: 0.5, outer: 0.5), false),

            (numPoints: 6, n: 3,
             offsets: (in: -0.45, out: 0.35), perturbLimits: (inner: 0.0, outer: 0.0), false),

            (numPoints: 24, n: 1.0,
             offsets: (in: 0.1, out: 0.5), perturbLimits: (inner: 0.5, outer: 0.5), false)
        ]
    
    @ObservedObject var model = Model()
 
    let description: PageDescription
    let size: CGSize
    
    var pageType: PageType
    
    @State var randomizeNextZigZagRedraw = false
    @State var showLayerSelectionList = true
    @State var showDrawingOptionsList = false

    /*
     EXPERIMENTAL
     unfinished exploration of using a dictionary for superEllipseLayers
     with bindings working in order to so something like ...
    
        if SELayers().isVisible(layerType: .blob_filled) {
            AnimatingBlob_Filled(curve: model.blobCurve)
        }
    */
    struct SELayers {

        // bit of play with a dictionary of layers rather than an array
        @State var superEllipseLayers : [LayerType : SuperEllipseLayer] =
        [
            LayerType.blob_stroked:
                .init(type: .blob_stroked, section: .animating, name: "blob (stroked)", visible: true),
            LayerType.blob_filled:
                .init(type: .blob_filled, section: .animating, name: "blob (filled)", visible: false),
        ]

        func isVisible(layerType: LayerType) -> Bool {
            return superEllipseLayers[layerType]!.visible
        }
    }
    
    //MARK:- [SuperEllipseLayers] array initialization
    @State var superEllipseLayers : [SuperEllipseLayer] =
    [
        // 'visible = true' here determines the initial appearance or lack thereof.
        // this is switchable thereafter via selection in the LayerSelectionList dlog
        
        // NOTA: changes to .init's ordering here need to be reflected by similar
        // changes in enum LayerType case ordering -- obviated by better design perhaps?
        
        .init(type: .blob_stroked, section: .animating, name: "blob stroked"),
        .init(type: .blob_filled, section: .animating, name: "blob filled"),
        .init(type: .blob_vertex_0_Marker, section: .animating, name: "blob - vertex [0] marker",
    visible: true),
        .init(type: .blob_markers, section: .animating, name: "blob - all markers"),
        .init(type: .zigZagsPlusMarkers, section : .animating, name: "zig-zags + markers"),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        .init(type: .baseCurve, section: .support, name: "base curve",
    visible: true),
        .init(type: .baseCurve_markers, section : .support, name: "base curve markers",
    visible: true),
        .init(type: .normals, section : .support, name: "normals"),
        .init(type: .envelopeBounds, section: .support,  name: "offsets",
    visible: true),
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
            
    //MARK:-
    //MARK: show these SuperEllipse layer stacks if flagged.
    //MARK: higher-numbered stacks occlude lower ones
    //MARK:-

    // BLOB (ANIMATING -- FILLED)
            //MARK: layer 1.  AnimatingBlob_Filled
            
                if superEllipseLayers[LayerType.blob_filled.rawValue].visible {
                    AnimatingBlob_Filled(curve: model.blobCurve)
                }
                
    // BLOB (ANIMATING -- STROKED)
                //MARK: layer 2.  AnimatingBlob_Stroked
                if superEllipseLayers[LayerType.blob_stroked.rawValue].visible {
                    AnimatingBlob_Stroked(curve: model.blobCurve)
                }
            
    // ZIG-ZAGS -- CURVES
            //MARK: layer 3. ZigZags
            if superEllipseLayers[LayerType.zigZagsPlusMarkers.rawValue].visible {
                ZigZags(curves: model.zigZagCurves)
            }
            
            // combine lines and markers to avoid the 10-view limit
    // NORMALS + MARKERS
            //MARK: layer 4.  NormalsPlusMarkers
            if superEllipseLayers[LayerType.normals.rawValue].visible {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   style: markerStyles[.envelopeBounds]!)
            }
    // BASE CURVE
            //MARK: layer 5.  BaseCurve
            if superEllipseLayers[LayerType.baseCurve.rawValue].visible {
                BaseCurve(vertices: model.baseCurve.vertices)
            }
            
            // see above. EnvelopeBounds() now draws both the bounds + the inner
            // & outer markers, priorly the remit of NormalsPlusMarkers
    // ENVELOPE BOUNDS
            //MARK: layer 6.  EnvelopeBounds
            if superEllipseLayers[LayerType.envelopeBounds.rawValue].visible {
                EnvelopeBounds(curves: model.boundingCurves,
                               style: markerStyles[.envelopeBounds]!)
            }
    // ZIG-ZAG -- MARKERS
            //MARK: layer 7. ZigZag_Markers
            if superEllipseLayers[LayerType.zigZagsPlusMarkers.rawValue].visible {
                ZigZag_Markers(curves: model.zigZagCurves,
                               zigStyle : markerStyles[.zig]!,
                               zagStyle : markerStyles[.zag]!)
            }

            // otherwise we're over our 10-View limit
            Group {
                // BASE CURVE MARKERS
                //MARK: layer 8. BaseCurve_Markers
                if superEllipseLayers[LayerType.baseCurve_markers.rawValue].visible {
                    BaseCurve_Markers(curve: model.baseCurve.vertices,
                                      style: markerStyles[.baseCurve]!)
                }
                // BLOB MARKERS (ANIMATING)
                //MARK: layer 9.  AnimatingBlob_Markers
                if superEllipseLayers[LayerType.blob_markers.rawValue].visible {
                    AnimatingBlob_Markers(curve: model.blobCurve,
                                          style: markerStyles[.blob]!)
                }
                // VERTEX[0] MARKER (ANIMATING)
                //MARK: layer 10. AnimatingBlob_VertexOriginMarker
                if superEllipseLayers[LayerType.blob_vertex_0_Marker.rawValue].visible {
                    AnimatingBlob_VertexOriginMarker(animatingCurve: model.blobCurve,
                                                     markerStyle: markerStyles[.vertexOrigin]!)
                }
            }
        }
        .onAppear
        {
            print("PageView.onAppear( PageType.\(pageType.rawValue) )" )
        }
        .onDisappear
        {
            print("PageView.onDisappear( PageType.\(pageType.rawValue) )")
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
               // model.animateBlobCurveToNextPhase()
                model.animateToNextZigZagPhase()
            }
            
            if showLayerSelectionList {
                showLayerSelectionList.toggle()
            }
        }
            
        // a nice thought, but makes center of shape quite busy
        // .overlay(bullseye(color: .green))
        
        .overlay(displaySuperEllipseMetrics())
        .displayScreenSizeMetrics(frontColor: .black, backColor: Color.init(white: 0.6))
        
        // push LayerSelectionList & TwoButtonPanel into the
        // lower-left corner. only one of them is visible at a time.
        
        .overlay(
            VStack {
                Spacer()
                HStack {
                    let s = CGSize(width: 270, height: 625)
                    
                    let range123 = 1..<4
                    let range456 = 4..<7

                    if showLayerSelectionList {
                        ZStack {
                            //LayerSelectionList(listItems: $superEllipseLayers)
                                             
                            List {
                                Section(header: Text("range 123")) {
                                    ForEach( range123 ) { i in Text("\(i)") }
                                }

                                Section(header: Text("range 456")) {
                                    ForEach( range456 ) { j in Text("\(j)") }
                                }
                            }
                            .frame(width: s.width, height: s.height)
                            
                            bezelFrame(color: .orange, size: s)
                        }
                        .padding(75)
                    }
                    else {
                        DrawingAndLayeringButtons(
                            showDrawingOptionsList: $showDrawingOptionsList,
                            showLayerSelectionList: $showLayerSelectionList
                        )
                        .padding(75)
                    }
                    
                    Spacer() // pushes to the left
                }
            }
        )
    }
    
    struct DrawingAndLayeringButtons : View {
        @Binding var showDrawingOptionsList : Bool
        @Binding var showLayerSelectionList : Bool
        
        var body: some View {
            HStack {
                DrawingOptionsButton(name: pencilInSquare,
                                          faceColor: .blue,
                                          edgeColor: .orange)
                    .onTapGesture {
                        print("DrawingOptions Button tapped")
                        showDrawingOptionsList.toggle()
                    }
                
                Spacer()
                    .frame(width: 60, height: 1)
                
                LayerSelectionListButton(faceColor: .blue,
                                         edgeColor: .orange)
                    .onTapGesture {
                        print("LayerSelectionList Button tapped")
                        showLayerSelectionList.toggle()
                    }
            }
            .scaleEffect(1.4)
        }
    }
    
    // a bit of eye candy
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
//        let colors : [Color] = [.init(white: 0.65), .init(white: 0.3)]
        let colors : [Color] = [.init(white: 0.7), .init(white: 0.25)]

        return LinearGradient(gradient: Gradient(colors: colors),
                              startPoint: .topLeading,
                              endPoint: .bottom)
    }
    
    func displaySuperEllipseMetrics() -> some View {
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
