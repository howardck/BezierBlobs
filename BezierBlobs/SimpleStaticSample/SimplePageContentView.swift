//
//  SinglePageView.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-08-02.
//

import SwiftUI

struct SimplePageContentView: View {
    
    enum ConstructionType {
        case handConstructed
        case superEllipseConstructed
    }
    
    var constructionType: ConstructionType
    
    // hand-construct something that's roughly circle'ish w/ appropriate
    // orthogonals. (fits nicely on my iPad mini; YMMV for other devices)
    
    let sampleData : [(vertex: CGPoint, normal: CGVector)] = [
        
        (CGPoint(x: 340, y: 0), CGVector(dx: 1, dy: 0)),
        (CGPoint(x: 260, y: -260), CGVector(dx: 0.707, dy: -0.707)),
        
        (CGPoint(x: 0, y: -340), CGVector(dx: 0, dy: -1)),
        (CGPoint(x: -260, y: -260), CGVector(dx: -0.707, dy: -0.707)),
        
        (CGPoint(x: -340, y: 0), CGVector(dx: -1, dy: 0)),
        (CGPoint(x: -260, y: 260), CGVector(dx: -0.707, dy: 0.707)),
        
        (CGPoint(x: 0, y: 340), CGVector(dx: 0, dy: 1)),
        (CGPoint(x: 260, y: 260), CGVector(dx: 0.707, dy: 0.707))
    ]
    
    let smoothed = false

    var body: some View {
        
        GeometryReader { gr in
            
            Color.init(white: 0.8)
            GridBackground(lineColor: Gray.dark,
                           lineWidth: 0.25)
            
            switch( constructionType ) {
                    
                // baseCurve & ofset constructed from precalc'ed data
                case .handConstructed :
                    
                    SimpleStaticPageView(baseCurve: sampleData,
                                         size: gr.size,
                                         smoothed: smoothed)
                    
                // parametric superellipse calculations provide the data points.
                // baseCurve and offsetCurve sizes derived as ratio to screen size
                case .superEllipseConstructed :
                                        
                    SimpleStaticPageView(numPoints: 8,
                                         size: gr.size,
                                         baseCurveToScreenRatio: 0.5,
                                         offsetCurveToScreenRatio: 1.0,
                                         smoothed: smoothed)
            }
        }
    }
}

/* just playing around. not sure this serves any useful purpose but wth?! */
struct GridBackground: View {
    var lineColor: Color
    var lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            VStack {
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
            }
            .padding(.vertical, -20)
            HStack {
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
                Color.clear.border(lineColor, width: lineWidth).padding(-4.25)
            }
            .padding(.vertical, -20)
        }
    }
}
