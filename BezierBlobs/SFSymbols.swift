//
//  SFSymbols.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-14.
//  idea from Stewart Lynch video, "Two SwiftUI Enum Use Cases"

import SwiftUI

enum SFSymbol: String, View {
    
    case CLOSED_BOOK = "book.closed.fill"
    case CLOSED_TEXTBOOK = "text.book.closed.fill"
    
    case QUESTION_MARK = "questionmark"
    case QUESTION_MARK_CIRCLE = "questionmark.circle"
    case QUESTION_MARK_CIRCLE_FILL = "questionmark.circle.fill"
    case QUESTION_MARK_SQUARE = "questionmark.square"
    case QUESTION_MARK_SQUARE_FILL = "questionmark.square.fill"
    
    case KEY = "key"
    case KEY_FILL = "key.fill"
    
    case HAND_WAVE = "hand.wave"
    case HAND_WAVE_FILL = "hand.wave.fill"
    
    case ABC = "abc"
    
    case tab_1 = "1.circle.fill"
    case tab_2 = "2.circle.fill"
    case tab_3 = "3.circle.fill"
    case tab_4 = "4.circle.fill"
    
    case checkbox_unchecked = "rectangle.portrait"
    case checkbox_checked = "checkmark.rectangle.portrait.fill"
    
    // not usable with LayerStackSymbol body code. not sure why ...
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
