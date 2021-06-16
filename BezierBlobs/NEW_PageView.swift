//
//  NewPageView.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-16.
//

import SwiftUI

struct NEW_PageView: View {
    
    
    static let NIL_RANGE : Range<CGFloat>
                = 0..<CGFloat(SEParametrics.VANISHINGLY_SMALL_DOUBLE)
    //MARK:-
    static let timerTimeIncrement : Double = 3.8
    static let animationTimeIncrement : Double = 2.4
    static let timerInitialTimeIncrement : Double = 0.0

    static let animationStyle = Animation.easeOut(duration: PageView.animationTimeIncrement)

    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct NewPageView_Previews: PreviewProvider {
    static var previews: some View {
        NEW_PageView()
    }
}
