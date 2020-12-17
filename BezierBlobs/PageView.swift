//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

enum PageType : String {
    case circle = "CIRCLE"
    case sweptWing = "SWEPT WING"
    case superEllipse = "SUPER ELLIPSE"
    case mutant = "MUTANT"
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
    
    @State var settingsDialogIsVisible = false
    
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
        
    //MARK:-
    
    @State var showAnimatingBlob = true
    @State var showNormalsPlusMarkers = true
    @State var showBaseCurve = true
    @State var showZigZagCurves = false
    @State var showEnvelopeBounds = true
    @State var showZigZag_Markers = false
    @State var showBaseCurve_Markers = true
    @State var showAnimatingBlob_Markers = true
    @State var showAnimatingBlob_PointZeroMarker = true
    
    //MARK:-
    var body: some View {
    
        ZStack {
            
            pageGradientBackground()

            if showAnimatingBlob {
                AnimatingBlob(curve: model.blobCurve,
                              stroked: true,
                              filled: true)
            }
            if showZigZagCurves {
                zigZagCurves(curves: model.zigZagCurves)
            }
            // combine lines and markers to avoid 10-view limit
            if showNormalsPlusMarkers {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   style: markerStyles[.envelopeBounds]!)
            }
            if showBaseCurve {
                BaseCurve(vertices: model.baseCurve.vertices)
            }
            if showEnvelopeBounds {
                //zigZagBounds(curves: model.boundingCurves)
                EnvelopeBounds(curves: model.boundingCurves)
            }
            if showZigZag_Markers {
                ZigZag_Markers(curves: model.zigZagCurves,
                               zigStyle : markerStyles[.zig]!,
                               zagStyle : markerStyles[.zag]!)
            }
            
            if showAnimatingBlob_Markers {
                AnimatingBlob_Markers(curve: model.blobCurve,
                                      style: markerStyles[.blob]!)
            }
            if showBaseCurve_Markers {
                BaseCurve_Markers(curve: model.baseCurve.vertices,
                                  style: markerStyles[.baseCurve]!)
            }
            if showAnimatingBlob_PointZeroMarker {
                AnimatingBlob_PointZeroMarker(animatingCurve: model.blobCurve,
                                              markerStyle: markerStyles[.pointZero]!)
            }
        }
        .measure(color: .yellow)
        .onAppear() {
            print("PageView.onAppear(PageType.\(self.pageType.rawValue))")
            
            // blob curve first appearance
//            model.blobCurve = model.baseCurve.vertices
            model.blobCurve = model.boundingCurves.inner
        }
        .onTapGesture(count: 1) {
            print("PageView.onTapGesture(PageType.\(self.pageType.rawValue))")
                        
            withAnimation(Animation.easeInOut(duration: 1.5)) {

                model.animateToNextZigZagPhase()
            }
        }
        
        // put GearButton in lower-right corner. a cleaner way... ????
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    if settingsDialogIsVisible {
                        Rectangle()
                            .frame(width: 100, height: 200)
                            .foregroundColor(Color.white)
                            .border(Color.red)
                            .padding(60)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 2.0))
                            .onTapGesture {
                                
                                settingsDialogIsVisible.toggle()
                            }
                    }
                    else {
                        GearButton(edgeColor: .orange, faceColor: .blue)
                            .scaleEffect(1.25)
                            .padding(60)
                            .onTapGesture {
                                print("GEAR BUTTON TAPPED!")
                                
                                settingsDialogIsVisible.toggle()
                            }
                    }
                }
            }
        )
        .overlay(dropShadowedTextDescription())
    }

    //MARK:-
    private func pageGradientBackground() -> some View {
        let colors : [Color] = [.init(white: 0.65), .init(white: 0.3)]
        return LinearGradient(gradient: Gradient(colors: colors),
                              startPoint: .top,
                              endPoint: .bottom)
    }
    
    private func zigZagCurves(curves: ZigZagCurves) -> some View {
        ZStack {
            let lineStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
            
            SuperEllipse(curve: curves.zig,
                         bezierType: .lineSegments)
                .stroke(Color.green, style: lineStyle)
            
            SuperEllipse(curve: curves.zag,
                         bezierType: .lineSegments)
                .stroke(Color.red, style: lineStyle)
        }
    }
    
    private func zigZagBounds(curves: BoundingCurves) -> some View {
        Group {
            let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
            let color = Color.init(white: 0.15)
            
            SuperEllipse(curve: curves.inner,
                         bezierType: .lineSegments)
                .stroke(color, style: strokeStyle)
            
            SuperEllipse(curve: curves.outer,
                         bezierType: .lineSegments)
                .stroke(color, style: strokeStyle)
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
                        .frame(width: 300, height: 30, alignment: .leading)
                        .padding(6)
                        .background(Color.white)
                        .padding(6)
                    Text("me too!")
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
//        .border(Color.red, width: 3)
    }
    
    func dropShadowedTextDescription() -> some View {
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
