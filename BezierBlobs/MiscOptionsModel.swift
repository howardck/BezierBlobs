//
//  MiscOptionsModel.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-11.
//

import Combine
import SwiftUI

enum PerturbationType : String {
    case staticZigZags = "static zig-zags"
    case randomizedZigZags = "randomized zig-zags"
    case randomAnywhereInEnvelope = "random anywhere in envelope"
}

enum NEW_PerturbationType : String, Equatable, CaseIterable {
    case staticZigZags = "fixed zig-zags"
    case randomizedZigZags = "randomized alternating zig-zags"
    case randomAnywhereInHalfEnvelope = "random alternating in half-envelope"
    case randomAnywhereInEnvelope = "random anywhere in envelope"
}

struct PerturbationTypeOption {
    var type : PerturbationType
    var isSelected: Bool
}

class MiscOptionsModel: ObservableObject {
    
    @Published var smoothed = true
    @Published var currPerturbationOption = PerturbationType.randomizedZigZags
    
    @Published var currPerturbationType: NEW_PerturbationType = .staticZigZags
    
// EXPERIMENTAL
// EXPERIMENTAL
    @Published var enumPerturbType : PerturbationType = .randomizedZigZags
// EXPERIMENTAL
// EXPERIMENTAL
    
    @Published var perturbationOptions : [PerturbationTypeOption] = [
        
        .init(type: .staticZigZags, isSelected: false),
        .init(type: .randomizedZigZags, isSelected: true),
        .init(type: .randomAnywhereInEnvelope, isSelected: false)
    ]

    func isSelected(perturbationType: PerturbationType) -> Bool {
        perturbationOptions.filter{
            $0.type == perturbationType && $0.isSelected }.count == 1
    }
}

