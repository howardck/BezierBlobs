//
//  MiscOptionsModel.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-11.
//

import Combine
import SwiftUI

// the OLD way of doing things
//enum PerturbationType : String {
//    case staticZigZags = "static zig-zags"
//    case randomizedZigZags = "randomized zig-zags"
//    case randomAnywhereInEnvelope = "random anywhere in envelope"
//}

// the NEW way we're transitioning to
enum PerturbationStrategy : String, Equatable, CaseIterable {
    case staticZigZags = "static fixed zig-zags"
    case randomizedZigZags = "randomized zig-zags"
}

class MiscOptionsModel: ObservableObject {
    
    @Published var smoothed = true
    @Published var currPerturbStrategy = PerturbationStrategy.randomizedZigZags
}

