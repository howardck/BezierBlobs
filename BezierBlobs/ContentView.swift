//
//  ContentView.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-10-21.
/*
    this project has been thru several transmutations. it started life
    as BezierBlob (singular), was then transformed into TabViews (which
    was begun primarily to explore the use of tabs to expand the number
    of views on display for pedagogic purposes), and now exists
    as what you're looking at.
 */

import SwiftUI

struct ContentView: View {
    
    var ps: PlatformSpecifics!
    var sizeClass : PlatformSpecifics.SizeClass!
    
    // can't get any higher up in the view hierarchy than here
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        print("ContentView.init()")
    }
        
    var body: some View {
                
        let deviceType = PlatformSpecifics.sizeClassForDevice(vSizeClass!,
                                                              hSizeClass!)
        GeometryReader { gr in
            TabView {

                PageView(descriptors: PageDescriptors.circle,
                         size: gr.size,
                         deviceType: deviceType)
                    .tabItem {
                        SFSymbol.tab_1
                        Text("\(PageDescriptors.circle.pageType.rawValue)")
                    }
                
                PageView(descriptors: PageDescriptors.classicSE,
                         size: gr.size,
                         deviceType: deviceType)
                    .tabItem {
                        SFSymbol.tab_2
                        Text("\(PageDescriptors.classicSE.pageType.rawValue)" )
                    }

                PageView(descriptors: PageDescriptors.deltaWing,
                         size: gr.size,
                         deviceType: deviceType)
                    .tabItem {
                        SFSymbol.tab_3
                        Text("\(PageDescriptors.deltaWing.pageType.rawValue)" )
                    }

                PageView(descriptors: PageDescriptors.rorschach,
                         size: gr.size,
                         deviceType: deviceType)
                    .tabItem {
                        SFSymbol.tab_4
                        Text("\(PageDescriptors.rorschach.pageType.rawValue)" )
                  }
                
                ZStack {
                    PageGradientBackground()
                        .overlay(
                            ZStack {
                                Color.orange
                                VStack {
                                    Text("Welcome. Enjoy!")
                                    Text("ほかに言う事あるか")
                                    Text("Howard Katz")
                                    Spacer()
                                        .frame(height: 10)
                                    Text("(No, that’s probably it)")
                                }
                                .font(.title3)
                                .foregroundColor(.white)
                                
                            }
                            .frame(width: 340, height: 300)
                            .border(Color.white, width: 1)
                        )
                }
                .tabItem {
                    SFSymbol.HAND_WAVE_FILL
                    Text("WELCOME")
                }
            }
//            .onChange(of: scenePhase) { newPhase in
//                if newPhase == .inactive {
//                    print( "%%%%%%% INACTIVE")
//                }
//                else if newPhase == .active {
//                    print( "%%%%%%% ACTIVE")
//                }
//                else if newPhase == .background {
//                    print( "%%%%%%% BACKGROUND")
//                }
//                else {
//                    print( "%%%%%%% UNKNOWN SCENE PHASE !!!!!")
//                }
//            }
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
    @Published var allVertices: Color
    @Published var evenNumberedVertices: Color
    @Published var vertex0Marker: Color
    @Published var offsetMarkers: Color
    @Published var baseCurveMarkers: Color
    
    init(background: Color,
         stroke: Color,
         fill: Color,
         buttonFace: Color,
         buttonEdge: Color,
         allVertices: Color,
         evenNumberedVertices: Color,
         vertex_0: Color,
         offsetMarkers: Color,
         baseCurveMarkers: Color) {

        self.background = background
        self.stroke = stroke
        self.fill = fill
        self.buttonFace = buttonFace
        self.buttonEdge = buttonEdge
        self.allVertices = allVertices
        self.evenNumberedVertices = evenNumberedVertices
        self.vertex0Marker = vertex_0
        self.offsetMarkers = offsetMarkers
        self.baseCurveMarkers = baseCurveMarkers
    }
}

struct Gray {
    static let light = Color.init(white: 0.8)
    static let dark = Color.init(white: 0.2)
}

//struct ContentView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let s = CGSize(width: 500, height: 500)
//
//        VStack {
//
//            HStack {
//            //------------------------------------------------------------
//                PageView(pageType: PageType.circle,
//                         descriptors: PageView.descriptions[0],
//                         size: s)
//                    .environmentObject(ColorScheme(background: Gray.light,
//                                                   stroke: .red,
//                                                   fill: .blue,
//                                                   buttonFace: .red,
//                                                   buttonEdge: .white,
//                                                   allVertices: .green,
//                                                   evenNumberedVertices: .green,
//                                                   vertex_0: .red))
//                    .environmentObject(SELayersViewModel())
//                    .environmentObject(MiscOptionsModel())
//
//                PageView(pageType: PageType.circle,
//                         descriptors: PageView.descriptions[0],
//                         size: s)
//                    .environmentObject(ColorScheme(background: Gray.light,
//                                                   stroke: .green,
//                                                   fill: .orange,
//                                                   buttonFace: .green,
//                                                   buttonEdge: .white,
//                                                   allVertices: .blue,
//                                                   evenNumberedVertices: .red,
//                                                   vertex_0: .green))
//                    .environmentObject(SELayersViewModel())
//                    .environmentObject(MiscOptionsModel())
//            }
//            //------------------------------------------------------------
//
//            HStack {
//            //------------------------------------------------------------
//                PageView(pageType: PageType.circle,
//                         descriptors: PageView.descriptions[0],
//                         size: s)
//                    .environmentObject(ColorScheme(background: Gray.dark,
//                                                   stroke: .blue,
//                                                   fill: .orange,
//                                                   buttonFace: .red,
//                                                   buttonEdge: .black,
//                                                   allVertices: .blue,
//                                                   evenNumberedVertices: .yellow,
//                                                   vertex_0: .red))
//                    .environmentObject(SELayersViewModel())
//                    .environmentObject(MiscOptionsModel())
//
//                PageView(pageType: PageType.circle,
//                         descriptors: PageView.descriptions[0],
//                         size: s)
//                    .environmentObject(ColorScheme(background: Gray.dark,
//                                                   stroke: .white,
//                                                   fill: Color.blue,
//                                                   buttonFace: .green,
//                                                   buttonEdge: .black,
//                                                   allVertices: .orange,
//                                                   evenNumberedVertices: .green,
//                                                   vertex_0: .red))
//                    .environmentObject(SELayersViewModel())
//                    .environmentObject(MiscOptionsModel())
//            }
//            //------------------------------------------------------------
//        }
//    }
//}
