//  BezierBlobs
//  SuperEllipseTheShape.swift
//
//  Created by Howard Katz on 2020-10-31.
//

import SwiftUI

enum BezierType : Equatable {
    case lineSegments
    case singleMarker(index: Int, radius: CGFloat)
    case someMarkers(indexSet: Set<Int>, radius: CGFloat)
    case allMarkers(radius: CGFloat)
    case normals
}

struct SuperEllipse : Shape {
    
    static let NUM_INTERPOLATED = 16
    
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
                
            case .singleMarker(let index, let radius) :
                if i == index {
                    path.move(to: point)
                    path.addMarker(of: radius)
                }
                
            case .someMarkers(let indexSet, let radius) :
                
                if indexSet.contains(i) {
                    path.move(to: point)
                    path.addMarker(of: radius)
                }
                
            case .allMarkers(let radius) :
                path.move(to: point)
                path.addMarker(of: radius)
                
                
        /*  for normals, even-numbered points lie on the inner offset.
            the next point is its outer offset counterpart.
         */
            case .normals :
                if i.isEven() && i < curve.count {
                    path.move(to: point)
                    path.addLine(to: curve[i+1])
                }
            }
        }
        if smoothed {
            path = path.smoothed(numInterpolated: SuperEllipse.NUM_INTERPOLATED)
        }
        
        // we could simply do a path.closeSubPath() instead of the following,
        // but the last normal before returning to the origin draws a bit strangely
        
        if bezierType != .normals {
            path.addLine(to: curve[0])
        }
        
        //path.closeSubpath()
        return path.offsetBy(dx: rect.width/2, dy: rect.height/2)
    }
}
