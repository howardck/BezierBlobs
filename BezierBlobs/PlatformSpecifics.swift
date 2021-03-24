//
//  PlatformSpecifics.swift
//  TabViews
//
//  Created by Howard Katz on 2020-11-03.
//

import SwiftUI

typealias Specifics = (name: String,
                       numPoints: Int)

struct PlatformSpecifics {
    static let IPHONE : Specifics = (
        name: "COMPACT",
        numPoints: 22
    )
    static let IPAD : Specifics = (
        name: "REGULAR",
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

