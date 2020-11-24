//
//  PlatformSpecifics.swift
//  TabViews
//
//  Created by Howard Katz on 2020-11-03.
//

import SwiftUI

typealias Specifics = (w: CGFloat, h: CGFloat,
                       in: CGFloat, out: CGFloat,
                       numPoints: Int)

struct PlatformSpecifics {
    static let IPHONE : Specifics = (
    // inset the baseCurve so that the outerCurve can fit onscreen
        w: 0.65,
        h: 0.75,
        in: -0.3,
        out: 0.3,
        numPoints: 22
    )
    static let IPAD : Specifics = (
        w: 0.70,
        h: 0.60,
        in: -0.3,
        out: 0.3,
        numPoints: 28
    )
    static func forSizeClasses(vSizeClass: UserInterfaceSizeClass,
                               hSizeClass: UserInterfaceSizeClass) -> Specifics
    {
        vSizeClass == .compact || hSizeClass == .compact ?
            PlatformSpecifics.IPHONE :
            PlatformSpecifics.IPAD
    }
}
