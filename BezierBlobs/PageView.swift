//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

typealias PageDescription = (numPoints: Int,
                             order: Double,
                             offsets: (in: CGFloat, out: CGFloat),
                             forceEqualAxes: Bool)

struct PageView: View {
    
    //MARK: TODO: (offsets should be +/- 1.0-based) -------------
    // OFFSETS HARD-WIRED FOR IPAD FOR THE MOMENT ...
    // ==================================
    
    static let SUPER_E_DESCRIPTORS : [PageDescription] =
        [
            (numPoints: 16, order: 2, offsets: (in: -0.4, out: 0.35), forceEqualAxes: true),
            (numPoints: 6, order: 3, offsets: (in: -0.65, out: 0.35), false),
            (numPoints: 18, order: 3, offsets: (in: -0.3, out: 0.3), false),
            (numPoints: 24, order: 0.9, offsets: (in: 0.1, out: 0.75), false)
        ]
    
    @ObservedObject var model = Model()
 
    let pageId: Int
    let description: PageDescription
    let size: CGSize
    
    init(pageId: Int, description: PageDescription, size: CGSize) {
        
        print("PageView.init()")
        
        self.pageId = pageId
        self.description = description
        
        self.size = CGSize(width: size.width * PlatformSpecifics.IPAD.w,
                           height: size.height * PlatformSpecifics.IPAD.h)
        
        // invoke once per each individual PageView instantiation
        model.calculateSuperEllipseCurves(for: pageId,
                                          pageDescription: description,
                                          axes: (a: Double(self.size.width/2),
                                                 b: Double(self.size.height/2)))
    }
    
    var body: some View {
        
        ZStack {
            Color.init(white: 0.45)
            
            // dynamic curves
            animatingBlobCurve(animatingCurve: model.blobCurve)
            animatingBlobCurveMarkers(animatingCurve: model.blobCurve)
            
            // static curves
            baseCurve(baseCurve: model.baseCurve)
            zigZagCurves(zigZagCurves: model.zigZagCurves)
            boundingCurves(boundingCurves: model.boundingCurves)
        }
        .onAppear() {
            print("PageView.onAppear()...")
            
            model.blobCurve = model.baseCurve
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

            if self.pageId == 1 {
                SuperEllipse(curve: animatingCurve,
                             bezierType: .lineSegments,
                             smoothed: true)
                    .fill(redGradient)
            }
            else if self.pageId == 2 {
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
    
    
    //MARK:-
    typealias MARKER_DESCRIPTOR = (color: Color, radius: CGFloat)
    
    let BLOB_MARKER : MARKER_DESCRIPTOR = (color: Color.yellow, radius: 17)
    let BASECURVE_MARKER : MARKER_DESCRIPTOR = (color: Color.white, radius: 11 )
    let BOUNDING_MARKER : MARKER_DESCRIPTOR = (color: Color.black, radius: 6)
    //MARK:-
    
    private func animatingBlobCurveMarkers(animatingCurve: [CGPoint]) -> some View {
        ZStack {

            // every animating vertex gets this style of marker
            SuperEllipse(curve: animatingCurve,
                         bezierType: .markers(radius: BLOB_MARKER.radius + 1),
                         smoothed: false)
                .fill(Color.init(white: 0.25))
            
            SuperEllipse(curve: animatingCurve,
                         bezierType: .markers(radius: BLOB_MARKER.radius),
                         smoothed: false)
                .fill(BLOB_MARKER.color)
            
            // but we mark vertex 0 specially so it points out the origin
            SuperEllipse(curve: animatingCurve,
                         bezierType: .singleMarker(index: 0, radius: BLOB_MARKER.radius + 1),
                         smoothed: false)
                .fill(Color.black)
            SuperEllipse(curve: animatingCurve,
                         bezierType: .singleMarker(index: 0, radius: BLOB_MARKER.radius),
                         smoothed: false)
                .fill(Color.green)
            
            SuperEllipse(curve: animatingCurve,
                         bezierType: .singleMarker(index: 0, radius: BLOB_MARKER.radius - 13),
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
                .stroke(Color.green, style: lineStyle)
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
                .fill(BOUNDING_MARKER.color)
            
        // outer curve
            SuperEllipse(curve: boundingCurves.outer,
                         bezierType: .lineSegments)
                .stroke(color, style: strokeStyle)
            SuperEllipse(curve: boundingCurves.outer,
                         bezierType: .markers(radius: BOUNDING_MARKER.radius))
                .fill(BOUNDING_MARKER.color)
        }
    }
    
    private func baseCurve(baseCurve: [CGPoint]) -> some View {
        ZStack {
       
            let strokeStyle = StrokeStyle(lineWidth: 1.5, dash: [4,3])
            
            SuperEllipse(curve: model.baseCurve,
                         bezierType: .lineSegments)
                .stroke(Color.white, style: strokeStyle)

            SuperEllipse(curve: model.baseCurve,
                         bezierType: .markers(radius: BASECURVE_MARKER.radius + 1))
                .fill(Color.black)
            
            SuperEllipse(curve: model.baseCurve,
                         bezierType: .markers(radius: BASECURVE_MARKER.radius))
                .fill(BASECURVE_MARKER.color)
        }
    }
    
    //MARK:-
    func textDescription() -> some View {
        ZStack {
    
            Text("numPoints: \(description.numPoints)")
                .font(.title)
                .foregroundColor(Color.init(white: 0.1))
                .offset(x: 2, y: 2)

            Text("numPoints: \(description.numPoints)")
                .font(.title)
                .foregroundColor(.white)
            
//            let w_s = "\((size.width).format(fspec:" 7.2"))"
//            let h_s = "\((size.height).format(fspec: "7.2"))"
//
//            Text("SE size: {W: \(w_s), H: \(h_s)}")
//                .font(.title2)
//                .foregroundColor(.yellow)
       }
//        .padding()
//        .background(Color.green)
   }
}

//MARK:-

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pageId: 1, description: PageView.SUPER_E_DESCRIPTORS[0], size: CGSize(width: 650, height: 550))
    }
}
