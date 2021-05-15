//
//  SFSymbols.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-14.
//  idea from Stewart Lynch video, "Two SwiftUI Enum Use Cases"

import SwiftUI

enum SFSymbol: String, View {
    
    case tab_1 = "1.circle.fill"
    case tab_2 = "2.circle.fill"
    case tab_3 = "3.circle.fill"
    case tab_4 = "4.circle.fill"
    
    case checkbox_unchecked = "rectangle.portrait"
    case checkbox_checked = "checkmark.rectangle.portrait.fill"
    
    // not usable with LayerStackSymbol body code
    // not sure why ...
    case layerStackIcon = "square.stack.3d.up"
    case diamondBullet = "diamond.fill"
    
    // stewart's example
//    case edit = "square.and.pencil"
//    case new = "plus"
//    case blog = "t.bubble.fill"
//    case website = "link.circle.fill"
//    case podcase = "mic.circle.fill"
//    case youtube = "arrowtriangle.right.square.fill"
    
    var body : some View {
        Image(systemName: rawValue)
    }
}
