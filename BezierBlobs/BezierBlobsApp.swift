//
//  BezierBlobsApp.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-11-24.

import SwiftUI

@main
struct BezierBlobsApp: App {
    
    //static let initialOddAndEvenVertexMarkersColor = Color.red

    var body: some Scene {
        WindowGroup {

//            TabViewTest()
//            EnumBasedListChooser()
//            TimerTest()
//            MainScreenLayoutTest()
//            MainScreenTwoButtonsTwoLists()

//            illustrate building a simple page of static curves
//            constructed either from hardcoded data or a superEllipse

//            SimplePageContentView(constructionType: .handConstructed)
            
            ContentView()
                
                .environmentObject(SELayersModel())
                .environmentObject(MiscOptionsModel())
            /*
                NOTA: MY ColorScheme object, not SwiftUI's. as well,
                the fill color below is at least currently being replaced
                by a gradient. see SELayersStack.filledAnimatingBlob().
            */
                .environmentObject(ColorScheme(background: Color.init(white: 0.75),
                                               stroke: .red,
                                               fill: .green,
                                               buttonFace: .red,
                                               buttonEdge: .white,
                                               evenNumberedVertices: .blue,
                                               oddNumberedVertices: .red,
                                               vertex0Marker: .yellow,
                                               orbitalVertexOuter: .blue,
                                               orbitalVertexInner: .red,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
        }
    }
}
