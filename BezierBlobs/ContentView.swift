//
//  ContentView.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-10-21.
/*
    this project has been thru several transmutations. it started life
    as BezierBlob (singular), was then transformed into TabViews (which
    was begun primarily to explore the use of tabs to expand the
    range of views on display for pedagogic purposes), and now exists
    as what you're looking at.
 */

import SwiftUI

struct ContentView: View {
    @Environment(\.verticalSizeClass) var vClass
    @Environment(\.horizontalSizeClass) var hClass
    
    var body: some View {
        GeometryReader { gr in
            
            let specifics = PlatformSpecifics.forSizeClasses(
                vSizeClass: vClass!,
                hSizeClass: hClass!)
            
            TabView {
                
                PageView(pageId: 1,
                         description: PageView.SUPER_E_DESCRIPTORS[0],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "record.circle")
                        Text("CIRCLE")
                    }
                
                PageView(pageId: 2,
                         description: PageView.SUPER_E_DESCRIPTORS[1],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "2.circle.fill")
                        Text("DELTA WING")
                }
                
                PageView(pageId: 3,
                         description: PageView.SUPER_E_DESCRIPTORS[2],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "3.circle.fill");
                        Text("SUPER ELLIPSE")
                    }

                PageView(pageId: 4,
                         description: PageView.SUPER_E_DESCRIPTORS[3],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "3.circle.fill");
                        Text("MUTANT MOTH")
                    }
           }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
