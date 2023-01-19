//
//  SimpleModel.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-12-29.
//

import SwiftUI

class SimpleModel : ObservableObject {
    
    var baseCurve = [(vertex: CGPoint, normal: CGVector)]()
    var offsetCurve = [CGPoint]()
    
    func calculateOffsetCurve(offset: Double) {
        offsetCurve = baseCurve.map{ $0.newPoint(at: offset, along: $1)}
    }
    
}
