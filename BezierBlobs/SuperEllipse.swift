//
//  SuperEllipse.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-31.
//

import SwiftUI

enum BezierType : Equatable {
    case lineSegments
    case markers(radius: CGFloat)
    case singleMarker(index: Int, radius: CGFloat)
    case normals
}

struct SuperEllipse : Shape {
    
    static let NUM_INTERPOLATED = 20
    
    var curve: [CGPoint]
    var bezierType: BezierType = .lineSegments
    var smoothed = false
    
    var animatableData: CGPointVector {
        get { return CGPointVector(values: curve) }
        set { curve = newValue.values }
    }
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        for (i, point) in curve.enumerated() {
            switch(bezierType) {
            
            case .lineSegments :
                i == 0 ?
                    path.move(to: point) :
                    path.addLine(to: point)
                
            case .markers(let radius) :
                path.move(to: point)
                path.addMarker(of: radius)
                
            case .singleMarker(let index, let radius) :
                if i == index {
                    path.move(to: point)
                    path.addMarker(of: radius)
                }
            /*  normals are specially "encoded" -- even-numbered points
                are on the inner envelope boundary; we line from each
                to its counterpart on the outer envelope boundary.
             */
            case .normals :
                if i.isEven() && i < curve.count {
                    path.move(to: point)
                    path.addLine(to: curve[i + 1])
                }
            }
        }
        if smoothed {
            path = path.smoothed(numInterpolated: SuperEllipse.NUM_INTERPOLATED)
        }
        
        // NOTA BUG: This produces an oddly heavier dashed line for
        // the last normal drawn if we DO close the path. but if
        // we don't closeSubpath(), no other paths get closed.
        
        path.closeSubpath()
        return path.offsetBy(dx: rect.width/2, dy: rect.height/2)
    }
}
