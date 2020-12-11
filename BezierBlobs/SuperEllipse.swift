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
    case normals_lineSegments
    case normals_endMarkers(radius: CGFloat)
}

struct SuperEllipse : Shape {
    
    static let NUM_INTERPOLATED = 16
    
    var curve: [CGPoint]
    var bezierType: BezierType
    var smoothed = false
    
    var animatableData: CGPointVector {
        get { return CGPointVector(values: curve) }
        set { curve = newValue.values }
    }
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        let points = curve.enumerated()
        for (i, point) in points {
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
            case .normals_lineSegments :
                if i < curve.count && i % 2 == 0 {
                    path.move(to: point)
                    path.addLine(to: curve[i + 1])
                }
            case .normals_endMarkers(let radius) :
                path.move(to: point)
                path.addMarker(of: radius)
            }
        }
        if smoothed {
            path = path.smoothed(numInterpolated: SuperEllipse.NUM_INTERPOLATED)
        }
        
        // NOTA: This produces a weird heavier dashed line only for
        // the LAST normal drawn if we do close the path.
        
        path.closeSubpath()
        return path.offsetBy(dx: rect.width/2, dy: rect.height/2)
    }
}
