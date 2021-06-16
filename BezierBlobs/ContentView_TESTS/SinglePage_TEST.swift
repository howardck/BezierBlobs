//
//  SinglePage_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-16.
//

import SwiftUI

struct SinglePage_TEST: View {
    var body: some View {
        
//        PageView(pageType: PageType.deltaWing,
//                 descriptors: PageView.descriptions[2],
//                 size: CGSize(width: 1400, height: 1000),
//                 deviceType: PlatformSpecifics.SizeClass.regular)
        TabView {
            NewPageView(descriptor: Descriptor.deltaWing,
                        size: CGSize(width: 1200, height: 800),
                        deviceType: PlatformSpecifics.SizeClass.regular)
                .tabItem {
                    SFSymbol.tab_1
                    Text("\(Descriptor.deltaWing.pageType.rawValue)")
                }
            
            NewPageView(descriptor: Descriptor.circle,
                        size: CGSize(width: 1200, height: 800),
                        deviceType: PlatformSpecifics.SizeClass.regular)
                .tabItem {
                    SFSymbol.tab_2
                    Text("\(Descriptor.circle.pageType.rawValue)")
                }
        }

    }
}

struct NewPageView : View {
    
    var descriptor: Descriptor
    var size: CGSize
    var deviceType: PlatformSpecifics.SizeClass
    
    var body : some View {
        
        Text("Testing new Descriptor format for {\(descriptor.pageType.rawValue)}")
            .frame(width: 1000, height: 200)
    }
}

struct SinglePage_TEST_Previews: PreviewProvider {
    static var previews: some View {
        SinglePage_TEST()
    }
}
