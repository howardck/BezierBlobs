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
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: Gray.dark,
                                               fill: .blue,
                                               buttonFace: .orange,
                                               buttonEdge: Gray.dark,
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
