//
//  BezierBlobsApp.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-11-24.
//

import SwiftUI

@main
struct BezierBlobsApp: App {

    var body: some Scene {
        WindowGroup {

            ContentView()
                
                .environmentObject(SELayersViewModel())
                .environmentObject(MiscOptionsModel())
                
            /*  I started using this terminology before discovering Apple's
                built-in light & dark mode support. this isn't that, and I'll
                leave this nomenclature in place until I need the former (if ever).
             */
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: Color.init(white: 0.1),
                                               buttonEdge: .orange,
                                               allVertices: .green,
                                               evenNumberedVertices: .red,
                                               vertex_0: .yellow,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
//            TabViewTest()
//            EnumBasedListChooser()
//            EmojiViewTest()
//            TimerTest()
//            MainScreenLayoutTest()
//            MainScreenTwoButtonsTwoLists()
        }
    }
}
