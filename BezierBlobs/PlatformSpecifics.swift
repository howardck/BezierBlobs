//
//  PlatformSpecifics.swift
//  TabViews
//
//  Created by Howard Katz on 2020-11-03.

// start of an exploration of better matching PageDesc parameters to the
// device they're on, to allow eg smaller bezier markers for iPhone say.
// abandoned at least for the moment

import SwiftUI

struct PlatformSpecifics {
    
    enum SizeClass {
        case compact
        case regular
    }
    
    let offset: CGFloat = 2.0
    
    static func radius(for deviceSize: SizeClass, markerType : MarkerType) -> CGFloat {
        
        return 0
    }
    
    static func baseMarkerRadiusFor(deviceSize: SizeClass) -> CGFloat {
        return 10
    }
    
    static func sizeClassForDevice(_ vSizeClass: UserInterfaceSizeClass,
                                   _ hSizeClass: UserInterfaceSizeClass) -> SizeClass {

            vSizeClass == .compact || hSizeClass == .compact ?
                SizeClass.compact :
                SizeClass.regular
    }
}

