//
//  BezierBlobsApp.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-11-24.
//

import SwiftUI

@main
struct BezierBlobsApp: App {
    
    let layers = Layers()
    let options = Options()
    
    var body: some Scene {
        WindowGroup {
            
//            ContentView()
//                .environmentObject(layers)
//                .environmentObject(options)
            
            // or ...
            // TimerTest()
            // TabViewTest()
             MainScreenLayoutTest()
        }
    }
}
