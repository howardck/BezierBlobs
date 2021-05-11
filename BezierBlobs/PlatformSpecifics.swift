//
//  PlatformSpecifics.swift
//  TabViews
//
//  Created by Howard Katz on 2020-11-03.

// start of an exploration of better matching PageDesc parameters to the
// device they're on, to allow eg smaller bezier markers for iPhone say.
// abandoned at least for the moment

import SwiftUI

typealias Specifics = (name: String,
                       numPoints: Int)

struct PlatformSpecifics {
    static let COMPACT : Specifics = (
        name: "COMPACT",
        numPoints: 22
    )
    static let REGULAR : Specifics = (
        name: "REGULAR",
        numPoints: 40
    )
    
    static func forSizeClasses(vSizeClass: UserInterfaceSizeClass,
                               hSizeClass: UserInterfaceSizeClass) -> Specifics
    {
        vSizeClass == .compact || hSizeClass == .compact ?
            PlatformSpecifics.COMPACT :
            PlatformSpecifics.REGULAR
    }
}

