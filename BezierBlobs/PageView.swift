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
    case mutantMoth = "MUTANT MOTH"
}

typealias PageDescription = (numPoints: Int,
                             n: Double,
                             offsets: (in: CGFloat, out: CGFloat),
                             forceEqualAxes: Bool)

struct PageView: View {
    
    var pageType: PageType
    
    // OFFSETS HARD-WIRED FOR IPAD FOR THE MOMENT ...
    // ==================================
    
    static let PAGE_INFO : [(PageType, PageDescription)] =
    [
        (PageType.circle,
                (numPoints: 16, n: 2, offsets: (in: -0.4, out: 0.35), forceEqualAxes: true)),
        (PageType.sweptWing,
                (numPoints: 6, n: 3, offsets: (in: -0.65, out: 0.35), false)),
        (PageType.superEllipse,
                (numPoints: 18, n: 3, offsets: (in: -0.3, out: 0.3), false)),
        // testing out why this goes wonky for points at the 4 'extreme' vertices
        (PageType.mutantMoth,
         (numPoints: 24, n: 0.9, offsets: (in: 0.1, out: 0.75), false))
//        (PageType.mutantMoth,
//                (numPoints: 4, n: 1.0, offsets: (in: -0.4, out: 0.6), false))
    ]
    
    static let DESCRIPTIONS : [PageDescription] =
        [
            (numPoints: 16, n: 2, offsets: (in: -0.4, out: 0.35), forceEqualAxes: true),
            (numPoints: 6, n: 3, offsets: (in: -0.65, out: 0.35), false),
            (numPoints: 26, n: 4.0, offsets: (in: -0.2, out: 0.3), false),
            
            // testing out why this goes wonky for points at the 4 'extreme' vertices
             (numPoints: 24, n: 0.9, offsets: (in: 0.1, out: 0.75), false)
//            (numPoints: 4, n: 1.0, offsets: (in: -0.4, out: 0.6), false)
        ]
    
    @ObservedObject var model = Model()
 
    let description: PageDescription
    let size: CGSize
    
    init(pageType: PageType, description: PageDescription, size: CGSize) {
        
        print("PageView.init()")
        
        self.pageType = pageType
        self.description = description
        
        self.size = CGSize(width: size.width * PlatformSpecifics.IPAD.w,
                           height: size.height * PlatformSpecifics.IPAD.h)
        
        // invoke once per each individual PageView instantiation
        model.calculateSuperEllipseCurves(for: pageType,
                                          pageDescription: description,
                                          axes: (a: Double(self.size.width/2),
                                                 b: Double(self.size.height/2)))
    }
    
    var body: some View {
        
        ZStack {
            Color.init(white: 0.6)

            // dynamic curves
            animatingBlobCurve(animatingCurve: model.blobCurve)
            
            baseCurveLineSegments(baseCurve: model.baseCurve.vertices)
            
//            zigZagCurves(zigZagCurves: model.zigZagCurves)

            normals(normals: model.calculateNormalsPseudoCurve())
            boundingCurves(boundingCurves: model.boundingCurves)
            animatingBlobCurveMarkers(animatingCurve: model.blobCurve)
            baseCurveMarkers(baseCurve: model.baseCurve.vertices)
    
        }
        .onAppear() {
            print("PageView.onAppear()...")
            
            model.blobCurve = model.baseCurve.vertices
        }
        .onTapGesture(count: 1) {
            print("PageView.onTapGesture() ...")
            withAnimation(Animation.easeInOut(duration: 1.5)) {

                model.animateToNextZigZagPosition()
            }
        }
        .overlay(sampleWidget())
        .overlay(textDescription())

        
    }
    
    //MARK:-
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
    
    //MARK:-

    let redGradient = LinearGradient(gradient: Gradient(colors: [Color.red, Color.yellow]),
                                     startPoint: .top, endPoint: .bottom)
    let blueGradient = LinearGradient(gradient: Gradient(colors: [Color.blue,
                                                                  Color.init(white: 0.8)]),
                                      startPoint: .top, endPoint: .bottom)
    
    //MARK:-
    private func animatingBlobCurve(animatingCurve: [CGPoint]) -> some View {
        ZStack {

            if self.pageType == .circle {
                SuperEllipse(curve: animatingCurve,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .fill(redGradient)
            }
            else if pageType == .sweptWing {
                SuperEllipse(curve: animatingCurve,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .fill(blueGradient)
                
                SuperEllipse(curve: animatingCurve,
                             bezierType: .lineSegments,
                             smoothed: false)
                    .fill(redGradient)
                
                SuperEllipse(curve: animatingCurve,
                             bezierType: .lineSegments,
                             smoothed: false)
                    .stroke(Color.init(white: 0.3), lineWidth: 1.0)
            }
//            else if pageId == 4 {
//                SuperEllipse(curve: animatingCurve,
//                             bezierType: .singleMarker(index: 0, radius: 20),
//                             smoothed: false)
//                    .fill(Color.blue)
//
//            }
            else {
                SuperEllipse(curve: animatingCurve,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .stroke(Color.init(white: 0.5), lineWidth: 1)
                
                SuperEllipse(curve: animatingCurve,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .fill(redGradient)
            }
        }
    }
    
    
    private func normals(normals: [CGPoint]) -> some View {
        
        ZStack {
            SuperEllipse(curve: normals,
                         bezierType: .normals_lineSegments)
                .stroke(Color.init(white: 1),
                        style: StrokeStyle(lineWidth: 4.0, dash: [0.5,3]))
//            SuperEllipse(curve: normals,
//                         bezierType: .normals_endMarkers(radius: 7))
//                .fill(Color.init(white: 0.15))
        }
    }
    
    //MARK:-
    typealias MARKER_DESCRIPTOR = (color: Color, radius: CGFloat)
    
    let BLOB_MARKER : MARKER_DESCRIPTOR = (color: Color.blue, radius: 16)
    let BASECURVE_MARKER : MARKER_DESCRIPTOR = (color: Color.white, radius: 16 )
    let BOUNDING_MARKER : MARKER_DESCRIPTOR = (color: Color.black, radius: 7)
    let ORIGIN_MARKER : MARKER_DESCRIPTOR = (color: Color.red, radius: 16)

    //MARK:-
    
    private func animatingBlobCurveMarkers(animatingCurve: [CGPoint]) -> some View {
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
            
            // but we mark vertex 0 specially so it points out the origin
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
    
    private func zigZagCurves(zigZagCurves: ZigZagCurves) -> some View {
        Group {
            let lineStyle = StrokeStyle(lineWidth: 2.0, dash: [4,2])
            
        // zig curve
            SuperEllipse(curve: zigZagCurves.zig,
                         bezierType: .lineSegments)
                .stroke(Color.blue, style: lineStyle)
        // zag curve
            SuperEllipse(curve: zigZagCurves.zag,
                         bezierType: .lineSegments)
                .stroke(Color.red, style: lineStyle)
        }
    }
    
    private func boundingCurves(boundingCurves: BoundingCurves) -> some View {
        Group {
            let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
            let color = Color.init(white: 0.15)
            
        // inner curve
            SuperEllipse(curve: boundingCurves.inner,
                         bezierType: .lineSegments)
                .stroke(color, style: strokeStyle)
            
            SuperEllipse(curve: boundingCurves.inner,
                         bezierType: .markers(radius: BOUNDING_MARKER.radius))
                .fill(color)
//                .fill(BOUNDING_MARKER.color)
            
        // outer curve
            SuperEllipse(curve: boundingCurves.outer,
                         bezierType: .lineSegments)
                .stroke(color, style: strokeStyle)
            
            SuperEllipse(curve: boundingCurves.outer,
                         bezierType: .markers(radius: BOUNDING_MARKER.radius))
                .fill(color)
//                .fill(BOUNDING_MARKER.color)
        }
    }
    
    private func baseCurveLineSegments(baseCurve: [CGPoint]) -> some View {
        Group {
            let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
            
            SuperEllipse(curve: model.baseCurve.vertices,
                         bezierType: .lineSegments)
                .stroke(Color.white, style: strokeStyle)
        }
    }
    
    private func baseCurveMarkers(baseCurve: [CGPoint]) -> some View {
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
    
    //MARK:-
    func textDescription() -> some View {
        VStack {
            ZStack {
                Text("numPoints: \(description.numPoints)")
                    .font(.title2)
                    .foregroundColor(.init(white: 0.2))
                    .offset(x: 2, y: 2)
                
                Text("numPoints: \(description.numPoints)")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            ZStack {
                Text("n: \(description.n.format(fspec: "3.1"))")
                    .font(.title2)
                    .foregroundColor(.init(white: 0.2))
                    .offset(x: 2, y: 2)
                
                Text("n: \(description.n.format(fspec: "3.1"))")
                    .font(.title2)
                    .foregroundColor(Color.white)
            }
        }
   }
    
    func dropShadowedText(name: String, value: String) -> some View {
        Text("TEST TEST TEST")
    }
}

//MARK:-

//struct PageView_Previews: PreviewProvider {
//    static var previews: some View {
//        PageView(pageType: PageType.circle, pageId: 1, description: PageView.SUPER_E_DESCRIPTORS[0], size: CGSize(width: 650, height: 550))
//    }
//}
