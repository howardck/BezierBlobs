//
//  PlatformSpecifics.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-11-03.

// start of an exploration of better matching PageDescriptors parameters
// to the device they're on, to eg allow smaller bezier markers for
// for iPhone say. abandoned, at least for the moment

import SwiftUI

struct PlatformSpecifics {
    
    enum SizeClass {
        case compact
        case regular
    }

    static func sizeClassForDevice(_ vSizeClass: UserInterfaceSizeClass,
                                   _ hSizeClass: UserInterfaceSizeClass) -> SizeClass {

            vSizeClass == .compact || hSizeClass == .compact ?
                SizeClass.compact :
                SizeClass.regular
    }
}

