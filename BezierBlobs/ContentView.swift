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
    
    struct StatusTracker {
        static var isInitialized : [PageType : Bool] = [
            .circle: false,
            .superEllipse: false,
            .deltaWing: false,
            .killerMoth: false
        ]
        static func isUninitialzed(pageType: PageType) -> Bool {
            return !ContentView.StatusTracker.isInitialized[pageType]!
        }
        static func markInited(pageType: PageType) {
            ContentView.StatusTracker.isInitialized[pageType] = true
        }
    }
    
    init() {
        print("ContentView.init()")
    }
    
    var body: some View {
        GeometryReader { gr in
            
            let _ = PlatformSpecifics.forSizeClasses(
                vSizeClass: vClass!,
                hSizeClass: hClass!)
            
            TabView {
                
                PageView(pageType: PageType.circle,
                         description: PageView.descriptions[0],
                         size: gr.size)
                    .onAppear{ print("TAB PAGE #1 appearing") }
                    .onDisappear{ print("TAB PAGE #1 disappearing") }
                    .tabItem {
                        Image(systemName: "1.circle.fill")
                        Text("\(PageType.circle.rawValue)")
                    }

                PageView(pageType: PageType.superEllipse,
                         description: PageView.descriptions[1],
                         size: gr.size)
                    .onAppear{ print("TAB PAGE #2 appearing") }
                    .onDisappear{ print("TAB PAGE #2 disappearing") }
                    .tabItem {
                        Image(systemName: "2.circle.fill")
                        Text("\(PageType.superEllipse.rawValue)" )
                    }
                
                PageView(pageType: PageType.deltaWing,
                         description: PageView.descriptions[2],
                         size: gr.size)
                    .onAppear{ print("TAB PAGE #3 appearing") }
                    .onDisappear{ print("TAB PAGE #3 disappearing") }
                    .tabItem {
                        Image(systemName: "3.circle.fill")
                        Text("\(PageType.deltaWing.rawValue)" )
                    }

                PageView(pageType: PageType.killerMoth,
                         description: PageView.descriptions[3],
                         size: gr.size)
                    .onAppear{ print("TAB PAGE #4 appearing") }
                    .onDisappear{ print("TAB PAGE #4 disappearing") }
                    .tabItem {
                        Image(systemName: "4.circle.fill");
                        Text("\(PageType.killerMoth.rawValue)" )
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PageView(pageType: PageType.deltaWing,
                     description: PageView.descriptions[3],
                     size: CGSize(width: 800, height: 800))
                .tabItem {
                    Image(systemName: "4.circle.fill");
                    Text("\(PageType.killerMoth.rawValue)" )
            }
            PageView(pageType: PageType.deltaWing,
                     description: PageView.descriptions[3],
                     size: CGSize(width: 800, height: 800))
                .tabItem {
                    Image(systemName: "4.circle.fill");
                    Text("\(PageType.killerMoth.rawValue)" )
                }
        }
    }
}
