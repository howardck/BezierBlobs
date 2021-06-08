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
            
//            TabViewTest()
//            //EnumBasedListChooser()
            
            // EmojiViewTest()
            // TimerTest()
            // MainScreenLayoutTest()
            // MainScreenTwoButtonsTwoLists()
        }
    }
}
