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
            (numPoints: 16, n: 2, offsets: (in: -0.2, out: 0.35), forceEqualAxes: true),
            (numPoints: 22, n: 4.0, offsets: (in: -0.2, out: 0.35), false),
            (numPoints: 6, n: 3, offsets: (in: -0.55, out: 0.35), false),
            (numPoints: 24, n: 1.0, offsets: (in: 0.1, out: 0.5), false)
        ]
    
    @ObservedObject var model = Model()
 
    let description: PageDescription
    let size: CGSize
    
    var pageType: PageType

    //MARK: - SHOW & HIDE THINGS
    
    @State var superEllipseLayerStackListIsVisible = false
    
    // "isVisible = true" entries below indicate which layers are VISIBLE BY DEFAULT @ startup
    @State var superEllipseLayers : [SuperEllipseLayer] =
    [
        .init(type: .animatingBlob, name: "animatingBlob", isVisible: true),
        .init(type: .animatingBlob_markers , name: "animatingBlob (all markers)", isVisible: true),
        .init(type: .animatingBlob_originMarkers, name: "animatingBlob (origin marker)", isVisible: true),
        .init(type: .baseCurve, name: "baseCurve", isVisible: true),
        .init(type: .baseCurve_markers, name: "baseCurve (markers)", isVisible: true),
        
        .init(type: .normals, name: "normals", isVisible: false),
        .init(type: .zigZags, name: "zigZags"),
        .init(type: .zigZag_markers, name: "ZigZag (markers)"),
        .init(type: .envelopeBounds, name: "envelope bounds", isVisible: true)
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
            // combine lines and markers to avoid 10-view limit
            if superEllipseLayers[LayerType.normals.rawValue].isVisible {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   style: markerStyles[.envelopeBounds]!)
            }
            if superEllipseLayers[LayerType.baseCurve.rawValue].isVisible {
                BaseCurve(vertices: model.baseCurve.vertices)
            }
            if superEllipseLayers[LayerType.envelopeBounds.rawValue].isVisible {
                EnvelopeBounds(curves: model.boundingCurves)
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
                AnimatingBlob_PointZeroMarker(animatingCurve: model.blobCurve,
                                              markerStyle: markerStyles[.pointZero]!)
            }
        }
        .measure(color: .yellow)
        .onAppear()
        {
            print("PageView.onAppear(PageType.\(pageType.rawValue))" )
        }
        // NB: check for 2 taps before checking for 1 tap
        .onTapGesture(count: 2) {
            withAnimation(Animation.easeInOut(duration: 0.6))
            {
                model.returnToInitialConfiguration()
            }
        }
        .onTapGesture(count: 1)
        {
            withAnimation(Animation.easeInOut(duration: 1.5))
            {
                model.animateToNextZigZagPhase()
            }
            
            if superEllipseLayerStackListIsVisible {
                superEllipseLayerStackListIsVisible = false
            }
        }
        
        // GearButton to lower-right corner. a cleaner way... ??
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if superEllipseLayerStackListIsVisible {
                        let s = CGSize(width: 376, height: 376)
                        ZStack {
                            SuperEllipseLayerSelectionList(listItems: $superEllipseLayers)
                                .frame(width: s.width, height: s.height)
                                .padding(50)
                            bezelFrame(color: .red, size: s)
                        }
                        
/* NOTA:    tapping here consumes the tap on the row that was tapped
            and we disappear w/out changing the row selection.
*/
//                        .onTapGesture {
//                            superEllipseLayerStackListIsVisible.toggle()
//                        }
                    }
                    else {
                        GearButton(edgeColor: .orange, faceColor: .blue)
                            .scaleEffect(1.25)
                            .padding(50)
                            .onTapGesture {
                                print("GEAR BUTTON TAPPED!")
                                
                                superEllipseLayerStackListIsVisible.toggle()
                            }
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
    
    //MARK:- OVERLAYS
    
    func sampleWidget() -> some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                VStack {
                    Text("I'm a widget")
                        .foregroundColor(.red)
                        .frame(width: 300, height: 30, alignment: .leading)
                        .padding(6)
                        .background(Color.white)
                        .padding(6)
                    Text("me too!")
                        .foregroundColor(.blue)
                        .frame(width: 300, height: 30, alignment: .leading)
                        .padding(6)
                        .background(Color.white)
                        .padding(6)
                }
                .border(Color.init(white: 0.25), width: 2)
                .background(Color.init(white: 0.85))
                .padding(40)
            }
        }
        .onTapGesture {
            print("sample widget tapped!")
            superEllipseLayerStackListIsVisible.toggle()
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
