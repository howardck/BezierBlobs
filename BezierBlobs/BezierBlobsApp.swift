//
//  BezierBlobsApp.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-11-24.
//

import SwiftUI

@main
struct BezierBlobsApp: App {
    
    let layersModel = LayersModel()
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(layersModel)
            
            //TimerTest()
            //TabViewTest()
            //MainScreenLayoutTest()
        }
    }
}
