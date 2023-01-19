//
//  MiscOptionsModel.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-11.
//

import Combine
import SwiftUI

enum PerturbationStrategy : String, Equatable, CaseIterable {
    case staticZigZags = "fixed endpoints"
    case randomizedZigZags = "randomized endpoints"
}

class MiscOptionsModel: ObservableObject {
    
    @Published var smoothed = true
    @Published var currPerturbStrategy = PerturbationStrategy.randomizedZigZags
    
    @Published var EXPERIMENTAL_normalsAlwaysOnTop = true
    @Published var EXPERIMENTAL_extendedNormals = false
}
