//
//  ContentView.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-10-21.
/*
    this project has been thru several transmutations. it started life
    as BezierBlob (singular), was then transformed into TabViews (which
    was used primarily to explore the use of tabs to expand the number
    of views on display for pedagogic purposes), and now exists
    as what you're looking at.
 */

import SwiftUI

struct ContentView: View {
    
    var ps: PlatformSpecifics!
    
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    init() {
        print("ContentView.init()")
    }
        
    var body: some View {

        let sizeClass = PlatformSpecifics.sizeClassForDevice(vSizeClass!,
                                                              hSizeClass!)
        GeometryReader { gr in
            
            TabView() {
                PageView(descriptors: PageDescriptors.deltaWing,
                         size: gr.size,
                         deviceSizeClass: sizeClass)
                    .tabItem ({
                        SFSymbols.tab_1
                        Text("\(PageDescriptors.deltaWing.pageType.rawValue)" )
                    })

                PageView(descriptors: PageDescriptors.circle,
                         size: gr.size,
                         deviceSizeClass: sizeClass)
                    .tabItem ({
                        SFSymbols.tab_2
                        Text("\(PageDescriptors.circle.pageType.rawValue)")
                    })

                PageView(descriptors: PageDescriptors.classicSE,
                         size: gr.size,
                         deviceSizeClass: sizeClass)
                    .tabItem ({
                        SFSymbols.tab_3
                        Text("\(PageDescriptors.classicSE.pageType.rawValue)" )
                    })

                PageView(descriptors: PageDescriptors.rorschach,
                         size: gr.size,
                         deviceSizeClass: sizeClass)
                    .tabItem ({
                        SFSymbols.tab_4
                        Text("\(PageDescriptors.rorschach.pageType.rawValue)" )
                    })
                
                WelcomePage()
                    .tabItem {
                        SFSymbols.HAND_WAVE_FILL
                        Text("WELCOME")
                }
            }
        }
    }
}

struct TestPrintSizeView : View {
    
    let size : CGSize
    var body: some View {
        
        Text("size: {" +
                "w: \((size.width).format(fspec: "6.2")), " +
                "h: \((size.height).format(fspec: "6.2"))" +
            "}")
    }
}

class ColorScheme : ObservableObject {
    @Published var background: Color
    @Published var stroke: Color
    @Published var fill: Color
    @Published var buttonFace: Color
    @Published var buttonEdge: Color
    @Published var evenNumberedVertices: Color
    @Published var oddNumberedVertices: Color
    @Published var vertex0Marker: Color
    @Published var orbitalVertexOuter: Color
    @Published var orbitalVertexInner: Color
    @Published var offsetMarkers: Color
    @Published var baseCurveMarkers: Color
    
    init(background: Color,
         stroke: Color,
         fill: Color,
         buttonFace: Color,
         buttonEdge: Color,
         evenNumberedVertices: Color,
         oddNumberedVertices: Color,
         vertex0Marker: Color,
         orbitalVertexOuter: Color,
         orbitalVertexInner: Color,
         offsetMarkers: Color,
         baseCurveMarkers: Color) {

        self.background = background
        self.stroke = stroke
        self.fill = fill
        self.buttonFace = buttonFace
        self.buttonEdge = buttonEdge
        self.evenNumberedVertices = evenNumberedVertices
        self.oddNumberedVertices = oddNumberedVertices
        self.vertex0Marker = vertex0Marker
        self.orbitalVertexOuter = orbitalVertexOuter
        self.orbitalVertexInner = orbitalVertexInner
        self.offsetMarkers = offsetMarkers
        self.baseCurveMarkers = baseCurveMarkers
    }
}

struct Gray {
    static let light = Color.init(white: 0.8)
    static let dark = Color.init(white: 0.35)
}
