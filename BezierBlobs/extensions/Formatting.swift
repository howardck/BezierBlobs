//
//  Formatting.swift
//  TabViews
//
//  Created by Howard Katz on 2020-11-01.
//

import SwiftUI
/*
 *  print(String(format: "%6.2f", 123.45678))
 *  -> "123.46"
 *  becomes:
 *  print("\(123.45678).format:fspec:"6.2"))")
 */
extension CGFloat {
    func format(fspec: String) -> String {
        return String(format: "%\(fspec)f", self)
    }
}
extension Double {
    func format(fspec: String) -> String {
        return String(format: "%\(fspec)f", self)
    }
}
extension Int {
    func format(fspec: String) -> String {
        String(format: "%\(fspec)ld", self)
    }
}
