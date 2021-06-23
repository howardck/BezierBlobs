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
                
        /*  I started using this nomenclature (ColorScheme) before discovering
            Apple's usage of the same name. I'll leave my nomenclature in place
            until and if I need the former, if ever.
         */
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: .red,
                                               buttonEdge: .yellow,
                                               allVertices: .green,
                                               evenNumberedVertices: .red,
                                               vertex_0: .orange,
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
