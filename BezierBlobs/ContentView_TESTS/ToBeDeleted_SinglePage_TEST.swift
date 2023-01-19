//
//  SinglePage_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-16.
//

import SwiftUI

struct ToBeDeleted_SinglePage_TEST: View {
    var body: some View {
        
//        PageView(pageType: PageType.deltaWing,
//                 descriptors: PageView.desdescriptions[2],
//                 size: CGSize(width: 1400, height: 1000),
//                 deviceType: PlatformSpecifics.SizeClass.regular)
        TabView {
            NewPageView(descriptor: PageDescriptors.deltaWing,
                        size: CGSize(width: 1200, height: 800),
                        deviceType: PlatformSpecifics.SizeClass.regular)
                .tabItem {
                    SFSymbol.tab_1
                    Text("\(PageDescriptors.deltaWing.pageType.rawValue)")
                }
            
            NewPageView(descriptor: PageDescriptors.circle,
                        size: CGSize(width: 1200, height: 800),
                        deviceType: PlatformSpecifics.SizeClass.regular)
                .tabItem {
                    SFSymbol.tab_2
                    Text("\(PageDescriptors.circle.pageType.rawValue)")
                }
        }

    }
}

struct NewPageView : View {
    
    var descriptor: PageDescriptors
    var size: CGSize
    var deviceType: PlatformSpecifics.SizeClass
    
    var body : some View {
        
        Text("Testing new Descriptor format for {\(descriptor.pageType.rawValue)}")
            .frame(width: 1000, height: 200)
    }
}

struct SinglePage_TEST_Previews: PreviewProvider {
    static var previews: some View {
        ToBeDeleted_SinglePage_TEST()
    }
}
