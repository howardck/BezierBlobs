//
//  BezierBlobsApp.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-11-24.
//

import SwiftUI

@main
struct BezierBlobsApp: App {
    
    let layers = SuperEllipseLayers()
    let options = Options()
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .environmentObject(layers)
                .environmentObject(options)
            
//            EmojiViewTest()
            
            // or ...
            // TimerTest()
            // TabViewTest()
            // MainScreenLayoutTest()
            // MainScreenTwoButtonsTwoLists()
        }
    }
}
