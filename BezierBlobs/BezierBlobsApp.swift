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
            
            SinglePage_TEST()
                
//            ContentView()
                
                .environmentObject(SELayersViewModel())
                .environmentObject(MiscOptionsModel())
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: Gray.dark,
                                               fill: .blue,
                                               buttonFace: .blue,
                                               buttonEdge: Color.init(white: 0.95),
                                               allVertices: .red,
                                               evenNumberedVertices: .green,
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
