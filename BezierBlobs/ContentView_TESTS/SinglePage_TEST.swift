//
//  SinglePage_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-16.
//

import SwiftUI

struct SinglePage_TEST: View {
    var body: some View {
        
        PageView(pageType: .deltaWing,
                 descriptors: PageView.descriptions[2],
                 size: CGSize(width: 1400, height: 1000),
                 deviceType: PlatformSpecifics.SizeClass.regular)

    }
}

struct SinglePage_TEST_Previews: PreviewProvider {
    static var previews: some View {
        SinglePage_TEST()
    }
}
