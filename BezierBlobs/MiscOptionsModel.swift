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
    case staticZigZags = "fixed zig-zags"
    case randomizedZigZags = "randomized alternating zig-zags"
    case randomAnywhereInHalfEnvelope = "random in alternating half-envelopes"
    case randomAnywhereInEnvelope = "random anywhere in envelope"
    case randomRangeFromAlternatingOffsets = "random range at offsets"
}

//struct PerturbationTypeOption {
//    var type : PerturbationType
//    var isSelected: Bool
//}

class MiscOptionsModel: ObservableObject {
    
    @Published var smoothed = true
//    @Published var currPerturbationOption = PerturbationType.randomizedZigZags
    
    @Published var currPerturbStrategy = PerturbationStrategy.randomRangeFromAlternatingOffsets
    
// EXPERIMENTAL
// EXPERIMENTAL
//    @Published var enumPerturbType : PerturbationType = .randomizedZigZags
// EXPERIMENTAL
// EXPERIMENTAL
    
//    @Published var perturbationOptions : [PerturbationTypeOption] = [
//        
//        .init(type: .staticZigZags, isSelected: false),
//        .init(type: .randomizedZigZags, isSelected: true),
//        .init(type: .randomAnywhereInEnvelope, isSelected: false)
//    ]
//
//    func isSelected(perturbationType: PerturbationType) -> Bool {
//        perturbationOptions.filter{
//            $0.type == perturbationType && $0.isSelected }.count == 1
//    }
}

