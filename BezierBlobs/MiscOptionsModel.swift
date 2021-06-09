//
//  MiscOptionsModel.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-11.
//

import Combine
import SwiftUI

enum PerturbationStrategy : String, Equatable, CaseIterable {
    case staticZigZags = "fixed perturbations"
    case randomizedZigZags = "randomized perturbations"
}

class MiscOptionsModel: ObservableObject {
    
    @Published var smoothed = true
    @Published var currPerturbStrategy = PerturbationStrategy.randomizedZigZags
}

