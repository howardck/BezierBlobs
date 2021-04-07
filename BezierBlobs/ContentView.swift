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

struct TestPrintSizeView : View {
    
    let size : CGSize
    var body: some View {
        
        Text("size: {" +
                "w: \((size.width).format(fspec: "6.2")), " +
                "h: \((size.height).format(fspec: "6.2"))" +
            "}")
    }
}

struct ContentView: View {
    
    var ps: PlatformSpecifics!
    
    @Environment(\.verticalSizeClass) var vClass
    @Environment(\.horizontalSizeClass) var hClass
    
    init() {
        print("ContentView.init()")
    }
        
    var body: some View {
        
        let ps = PlatformSpecifics.forSizeClasses(
            vSizeClass: vClass!,
            hSizeClass: hClass!)
               
        GeometryReader { gr in
            TabView {
                Group {
//                    TestPrintSizeView(size: gr.size)
//                        .font(.largeTitle)
//                        .foregroundColor(.blue)

                    PageView(pageType: PageType.superEllipse,
                             description: PageView.descriptions[0],
                             size: gr.size)
                        .tabItem {
                            Image(systemName: "1.circle.fill")
                            Text("\(PageType.superEllipse.rawValue)" )
                        }
                }
                
                PageView(pageType: PageType.circle,
                         description: PageView.descriptions[1],
                         size: gr.size)

                    .onAppear{ print("PageView.onAppear(PageType.CIRCLE)\n" +
                                     "         Platform { \(ps.name) }")}

                    .tabItem {
                        Image(systemName: "2.circle.fill")
                        Text("\(PageType.circle.rawValue)")
                    }
                
                PageView(pageType: PageType.deltaWing,
                         description: PageView.descriptions[2],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "3.circle.fill")
                        Text("\(PageType.deltaWing.rawValue)" )
                    }

                PageView(pageType: PageType.mutantMoth,
                         description: PageView.descriptions[3],
                         size: gr.size)
                    .tabItem {
                        Image(systemName: "4.circle.fill");
                        Text("\(PageType.mutantMoth.rawValue)" )
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
                    Text("\(PageType.mutantMoth.rawValue)" )
            }
            PageView(pageType: PageType.deltaWing,
                     description: PageView.descriptions[3],
                     size: CGSize(width: 800, height: 800))
                .tabItem {
                    Image(systemName: "4.circle.fill");
                    Text("\(PageType.mutantMoth.rawValue)" )
                }
        }
    }
}
