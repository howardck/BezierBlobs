//
//  SimpleStaticPageView.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-12-08.
//

import SwiftUI

extension SimpleStaticPageView {

    // this initializer for working with a fixed set of data
    // points, primarily for testing our basic static drawing algorithms
        
    init(baseCurve: [(vertex: CGPoint, normal: CGVector)],
         size: CGSize,
         smoothed: Bool) {

        self.numPoints = baseCurve.count
        self.size = size
        self.smoothed = smoothed
        
        let someOffsetDistance : Double = -20

        model.baseCurve = baseCurve
        model.calculateOffsetCurve(offset: someOffsetDistance )
    }
    
    // this initializer determines our data points by
    // calculating a parametric equation for a superellipse

    init(numPoints: Int,
         size: CGSize,
         baseCurveToScreenRatio: Double,
         offsetCurveToScreenRatio: Double,
         smoothed: Bool) {

        self.numPoints = numPoints
        self.size = size
        self.smoothed = smoothed

        let axes: Axes = (baseCurveToScreenRatio * 0.5 * size.width,
                          baseCurveToScreenRatio * 0.5 * size.height)
        
        let minAxis   = min(0.5 * size.width, 0.5 * size.height)
        let offset = minAxis * (offsetCurveToScreenRatio - baseCurveToScreenRatio)
        
        print("screenSize: (w: \(size.width), h:\(size.height))")
        print("baseCurveSemiAxes: (a: \(axes.a), b: \(axes.b))")

        print("baseCurveToScreenRatio: {\((baseCurveToScreenRatio).format(fspec: "4.2"))}")
        print("offsetToScreenRatio: {\((offsetCurveToScreenRatio).format(fspec: "4.2"))}")

        print("minSemiAxis: {\(minAxis)}")
        print("offset: {\((offset).format(fspec: "4.2"))}")
        
        // so-called 'n' == 3.5; I prefer the term 'order'; whatever ...
        model.baseCurve = SEParametrics.calculateSuperEllipse(order: 3.5,
                                                              for: numPoints,
                                                              with: axes)
        model.calculateOffsetCurve(offset: offset)
        
        if DEBUG.PRINT_OFFSET_COORDINATES {
            print("[[[[ DEBUG: SimpleModel.innerOffsetCurve: ]]]]")
            for (i, offset) in model.offsetCurve.enumerated() {
                DEBUG.printOffsetCoordinates(i: i, offsetPoint: offset)
            }
        }
    }
}

struct SimpleStaticPageView: View {
    
    static let offset : Double = -150
    
    static let markerRadius : CGFloat = 8
    
    var numPoints : Int = 0
    let size: CGSize
    var smoothed = true

    @ObservedObject var model = SimpleModel()
    
    var body: some View {
        ZStack {
            BaseCurve(curve: model.baseCurve.map{ $0.vertex },
                      color: .white, smoothed: smoothed)

            OffsetCurve(curve: model.offsetCurve,
                        color: .black,
                        smoothed: smoothed)
        }
    }
}

struct OffsetCurve: View {
    
    let curve: [CGPoint]
    let color: Color
    var smoothed = false
    
    var body: some View {
        
        lineSegments(curve: curve, color: color, smoothed: smoothed)
        
        allVertexMarkers(curve: curve,
                         outerColor: .black,
                         innerColor: .white)
    }
    
    func lineSegments(curve: [CGPoint], color: Color,
                      smoothed : Bool) -> some View {
        SuperEllipse(curve: curve,
                     bezierType: .lineSegments,
                     smoothed: smoothed)
            .stroke(color,
                    style: StrokeStyle(lineWidth: 1.5, dash: [5,3]) )
    }
    
    func allVertexMarkers(curve: [CGPoint],
                          outerColor: Color,
                          innerColor: Color) -> some View {
        ZStack {
            SuperEllipse(curve: curve,
                         bezierType: .allMarkers(radius: SimpleStaticPageView.markerRadius))
                .fill(outerColor)
            SuperEllipse(curve: curve,
                         bezierType: .allMarkers(radius: SimpleStaticPageView.markerRadius - 2))
                .fill(innerColor)
        }
    }
}

struct BaseCurve: View {
    
    let curve: [CGPoint]
    let color: Color
    var smoothed = false
    
    var body: some View {
        
        lineSegments(curve: curve, color: color, smoothed: smoothed)
        
        allVertexMarkers(curve: curve,
                         outerColor: .white,
                         innerColor: .black)
    }
    
    func lineSegments(curve: [CGPoint], color: Color,
                      smoothed : Bool) -> some View {
        SuperEllipse(curve: curve,
                     bezierType: .lineSegments,
                     smoothed: smoothed)
            .stroke(color,
                    style: StrokeStyle(lineWidth: 1.5, dash: [5,3]) )
    }
    
    func allVertexMarkers(curve: [CGPoint],
                          outerColor: Color,
                          innerColor: Color) -> some View {
        ZStack {
            SuperEllipse(curve: curve,
                         bezierType: .allMarkers(radius: SimpleStaticPageView.markerRadius))
                .fill(outerColor)
            SuperEllipse(curve: curve,
                         bezierType: .allMarkers(radius: SimpleStaticPageView.markerRadius - 2))
                .fill(innerColor)
        }
    }
}
