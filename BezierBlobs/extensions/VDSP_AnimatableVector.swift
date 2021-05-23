/*
    started life as AnimatableVector
    https://gist.github.com/mecid

    PROBLEM: this type of vector wraps [Double],
    while the CGPointVector I'm currently using uses [CGPoint]
*/

import SwiftUI
import enum Accelerate.vDSP

struct VDSP_AnimatableVector: VectorArithmetic {
    static var zero = VDSP_AnimatableVector(values: [0.0])

    static func + (lhs: VDSP_AnimatableVector, rhs: VDSP_AnimatableVector) -> VDSP_AnimatableVector {
        let count = min(lhs.values.count, rhs.values.count)
        return VDSP_AnimatableVector(values: vDSP.add(lhs.values[0..<count], rhs.values[0..<count]))
    }

    static func += (lhs: inout VDSP_AnimatableVector, rhs: VDSP_AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.add(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    static func - (lhs: VDSP_AnimatableVector, rhs: VDSP_AnimatableVector) -> VDSP_AnimatableVector {
        let count = min(lhs.values.count, rhs.values.count)
        return VDSP_AnimatableVector(values: vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count]))
    }

    static func -= (lhs: inout VDSP_AnimatableVector, rhs: VDSP_AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    var values: [Double]

    mutating func scale(by rhs: Double) {
        vDSP.multiply(rhs, values, result: &values)
    }

    var magnitudeSquared: Double {
        vDSP.sum(vDSP.multiply(values, values))
    }
}
