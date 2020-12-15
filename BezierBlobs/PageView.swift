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
    
    @State var settingsDialogIsVisible = false
    
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
    
    let orangishGradient = LinearGradient(gradient: Gradient(colors: [.yellow, .red]),
                                startPoint: .topLeading, endPoint: .bottomTrailing)
    
    @State var showAnimatingBlob = true
    @State var showNormals = true
    @State var showBaseCurve = false
    @State var showZigZagCurves = true
    @State var showZigZagBounds = true
    @State var showZigZag_Markers = true
    @State var showBaseCurve_Markers = true
    @State var showAnimatingBlob_Markers = true
    @State var showAnimatingBlob_ZeroPointMarker = false
    
    var body: some View {
        
        ZStack {
            
            pageGradientBackground()
                        
            if showAnimatingBlob {
                AnimatingBlob(curve: model.blobCurve, style: orangishGradient)
            }
            if showNormals {
                normals_Lines(pseudoCurve: model.calculateNormalsPseudoCurve())
            }
            if showBaseCurve {
                baseCurve(curve: model.baseCurve.vertices)
            }
            if showZigZagCurves {
                zigZagCurves(curves: model.zigZagCurves)
            }
            if showZigZagBounds {
                zigZagBounds(curves: model.boundingCurves)
            }
            if showZigZag_Markers {
                ZigZag_Markers(curves: model.zigZagCurves,
                               zigStyle : markerStyles[.zig]!,
                               zagStyle : markerStyles[.zag]!)
            }
            if showBaseCurve_Markers {
                BaseCurve_Markers(curve: model.baseCurve.vertices,
                                  style: markerStyles[.baseCurve]!)
            }
           if showAnimatingBlob_Markers {
                AnimatingBlob_Markers(curve: model.blobCurve,
                                      style: markerStyles[.blob]!)
           }
            if showAnimatingBlob_ZeroPointMarker {
                AnimatingBlob_PointZeroMarker(animatingCurve: model.blobCurve,
                                              markerStyle: markerStyles[.zeroPoint]!)
            }
        }
        .measure(color: .green)
        .onAppear() {
            print("PageView.onAppear()...")
            
            model.blobCurve = model.baseCurve.vertices
        }
        .onTapGesture(count: 1) {
            print("PageView.onTapGesture() ...")
            
            settingsDialogIsVisible.toggle()
            
            withAnimation(Animation.easeInOut(duration: 1.5)) {

                model.animateToNextZigZagPosition()
            }
        }
        
        // put GearButton in lower-right corner. cleaner way ????
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
        .overlay(textDescription())
    }
    
    //MARK:-
    private func pageGradientBackground() -> some View {
        let colors : [Color] = [.init(white: 0.3), .init(white: 0.7)]
        return LinearGradient(gradient: Gradient(colors: colors),
                              startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    struct PageGradientBackground : View {
        let colorRange : [Color] = [.init(white: 0.35), .init(white: 0.7)]
        var body : some View {
            LinearGradient(gradient: Gradient(colors: colorRange),
                                              startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    let redGradient = LinearGradient(gradient: Gradient(colors: [Color.red, Color.yellow]),
                                     startPoint: .top, endPoint: .bottom)
    let blueGradient = LinearGradient(gradient: Gradient(colors: [Color.blue,
                                                                  Color.init(white: 0.8)]),
                                      startPoint: .top, endPoint: .bottom)
    
    //MARK:-
    private func animatingBlob_Lines(animatingCurve: [CGPoint]) -> some View {
        
        SuperEllipse(curve: animatingCurve,
                     bezierType: .lineSegments,
                     smoothed: true)
            .fill(redGradient)
    }
    
    private func normals_Lines(pseudoCurve: [CGPoint]) -> some View {
        
        ZStack {
            SuperEllipse(curve: pseudoCurve,
                         bezierType: .normals_lineSegments)
                .stroke(Color.init(white: 1),
                        style: StrokeStyle(lineWidth: 4, dash: [0.75,3]))
            
//            SuperEllipse(curve: pseudoCurve,
//                         bezierType: .normals_endMarkers(radius: 4))
//                .fill(Color.black)//Color.init(white: 0.15))
        }
    }
    
    //MARK:-
    typealias MARKER_DESCRIPTOR = (color: Color, radius: CGFloat)
    
    let BLOB_MARKER : MARKER_DESCRIPTOR = (color: Color.green, radius: 16)
    let BASECURVE_MARKER : MARKER_DESCRIPTOR = (color: Color.white, radius: 16 )
    let BOUNDING_MARKER : MARKER_DESCRIPTOR = (color: Color.black, radius: 7)
    let ORIGIN_MARKER : MARKER_DESCRIPTOR = (color: Color.yellow, radius: 16)

    //MARK:-
    
    private func animatingBlob_PointZeroMarker(animatingCurve: [CGPoint]) -> some View {
        ZStack {

            SuperEllipse(curve: animatingCurve,
                         bezierType: .singleMarker(index: 0, radius: ORIGIN_MARKER.radius + 1),
                         smoothed: false)
                .fill(Color.black)
            SuperEllipse(curve: animatingCurve,
                         bezierType: .singleMarker(index: 0, radius: ORIGIN_MARKER.radius),
                         smoothed: false)
                .fill(ORIGIN_MARKER.color)
            
            SuperEllipse(curve: animatingCurve,
                         bezierType: .singleMarker(index: 0, radius: ORIGIN_MARKER.radius - 13),
                         smoothed: false)
                .fill(Color.white)
        }
    }
    
    //MARK:-
    
    private func blobCurve_Markers(animatingCurve: [CGPoint]) -> some View {
        ZStack {

            // every animating blob vertex gets this style of marker
            SuperEllipse(curve: animatingCurve,
                         bezierType: .markers(radius: BLOB_MARKER.radius + 1),
                         smoothed: false)
                .fill(Color.init(white: 0.0))
            
            SuperEllipse(curve: animatingCurve,
                         bezierType: .markers(radius: BLOB_MARKER.radius),
                         smoothed: false)
                .fill(BLOB_MARKER.color)
            
            SuperEllipse(curve: animatingCurve,
                         bezierType: .markers(radius: BLOB_MARKER.radius - 13),
                         smoothed: false)
                .fill(Color.init(white: 1))
            
            // -----------------------------------------------------------
            
        }
    }
    
    private func zigZagCurves_Markers(curves: ZigZagCurves) -> some View {
        
        ZStack {
            
            SuperEllipse(curve: curves.zig,
                         bezierType: .markers(radius: BASECURVE_MARKER.radius))
                .fill(Color.blue)
            
            SuperEllipse(curve: curves.zag,
                         bezierType: .markers(radius: BASECURVE_MARKER.radius))
                .fill(Color.red)
        }
    }
    
    private func zigZagCurves(curves: ZigZagCurves) -> some View {
        ZStack {
            let lineStyle = StrokeStyle(lineWidth: 2.0, dash: [4,2])
            
        // zig curve
            SuperEllipse(curve: curves.zig,
                         bezierType: .lineSegments)
                .stroke(Color.green, style: lineStyle)
        // zag curve
            SuperEllipse(curve: curves.zag,
                         bezierType: .lineSegments)
                .stroke(Color.red, style: lineStyle)
        }
    }
    
    private func zigZagBounds(curves: BoundingCurves) -> some View {
        Group {
            let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
            let color = Color.init(white: 0.15)
            
        // inner curve
            SuperEllipse(curve: curves.inner,
                         bezierType: .lineSegments)
                .stroke(color, style: strokeStyle)
            
//            SuperEllipse(curve: curves.inner,
//                         bezierType: .markers(radius: BOUNDING_MARKER.radius))
//                .fill(color)
////                .fill(BOUNDING_MARKER.color)
            
        // outer curve
            SuperEllipse(curve: curves.outer,
                         bezierType: .lineSegments)
                .stroke(color, style: strokeStyle)
            
//            SuperEllipse(curve: curves.outer,
//                         bezierType: .markers(radius: BOUNDING_MARKER.radius))
//                .fill(color)
////                .fill(BOUNDING_MARKER.color)
        }
    }

    private func baseCurve(curve: [CGPoint]) -> some View {

        Group {
            let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
            SuperEllipse(curve: model.baseCurve.vertices,
                         bezierType: .lineSegments)
                .stroke(Color.white, style: strokeStyle)
        }
    }
    
    private func baseCurve_Markers(curve: [CGPoint]) -> some View {
        ZStack {

            SuperEllipse(curve: model.baseCurve.vertices,
                         bezierType: .markers(radius: BASECURVE_MARKER.radius + 1))
                .fill(Color.black)
            
            SuperEllipse(curve: model.baseCurve.vertices,
                         bezierType: .markers(radius: BASECURVE_MARKER.radius))
                .fill(BASECURVE_MARKER.color)
            
            SuperEllipse(curve: model.baseCurve.vertices,
                         bezierType: .markers(radius: 4))
                .fill(Color.black)
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
    
    func textDescription() -> some View {
        VStack(spacing: 10) {
            ZStack() {
                Text("numPoints: \(description.numPoints)")
                    .font(.title)
                    .foregroundColor(.init(white: 0.2))
                    .offset(x: 2, y: 2)
                
                Text("numPoints: \(description.numPoints)")
                    .font(.title)
                    .foregroundColor(.white)
            }
            ZStack {
                Text("n: \(description.n.format(fspec: "3.1"))")
                    .font(.title)
                    .foregroundColor(.init(white: 0.2))
                    .offset(x: 2, y: 2)
                
                Text("n: \(description.n.format(fspec: "3.1"))")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
   }
    
    func dropShadowedText(name: String, value: String) -> some View {
        Text("TEST TEST TEST")
    }
}

//MARK:-

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pageType: PageType.circle, description: PageView.descriptions[0], size: CGSize(width: 650, height: 550))
    }
}
