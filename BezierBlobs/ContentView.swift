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
                
                PageView(pageType: PageType.circle,
                         description: PageView.DESCRIPTIONS[0],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "record.circle")
                        Text("\(PageType.circle.rawValue)")
                    }
                
                PageView(pageType: PageType.superEllipse,
                         description: PageView.DESCRIPTIONS[1],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "3.circle.fill")
                        Text("\(PageType.superEllipse.rawValue)" )
                    }
                
                PageView(pageType: PageType.sweptWing,
                         description: PageView.DESCRIPTIONS[1],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "2.circle.fill")
                        Text("\(PageType.sweptWing.rawValue)" )
                }

                PageView(pageType: PageType.mutant,
                         description: PageView.DESCRIPTIONS[3],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "4.circle.fill");
                        Text("\(PageType.mutant.rawValue)" )
                    }
           }
        
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pageType: PageType.mutant,
                 description: PageView.DESCRIPTIONS[3],
                 size: CGSize(width: 800, height: 800))
            .tabItem {
                Image(systemName: "4.circle.fill");
                Text("\(PageType.mutant.rawValue)" )
            }
    }
}
