//
//  SimpleShape.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-12-01.
//

import SwiftUI

enum SimpleBezierType: Equatable {
    case lineSegments
    case markers(radius: CGFloat)
}

struct SimpleShape: Shape {
    
    var curve: [CGPoint]
    var bezierType : SimpleBezierType
    var smoothed = false
    
//    not needed if we're just doing static curves.
//    see SuperEllipseShape.swift for a slightly different
//    solution if we're doing both static AND animating shapes
    
//    var animatableData: CGPointVector {
//        get { return CGPointVector(values: curve) }
//        set { curve = newValue.values }
//    }
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        for (i, point) in curve.enumerated() {
            switch(bezierType) {
                case .lineSegments :
                    i == 0 ?
                    path.move(to: point) : path.addLine(to: point)
                case .markers( let radius) :
                    path.move(to: point)
                    path.addMarker(of: radius)
            }
        }
        path.closeSubpath()
        return path.offsetBy(dx: rect.width/2, dy: rect.height/2)
    }
}
