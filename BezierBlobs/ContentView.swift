//
//  ContentView.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-10-21.
/*
    this project has been thru several transmutations. it started life
    as BezierBlob (singular), was then transformed into TabViews (which
    was begun primarily to explore the use of tabs to expand the
     of views on display for pedagogic purposes), and now exists
    as what you're looking at.
 */

import SwiftUI

struct ContentView: View {
    
    var ps: PlatformSpecifics!
    
    @Environment(\.verticalSizeClass) var vClass
    @Environment(\.horizontalSizeClass) var hClass
    
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        print("ContentView.init()")
    }
        
    var body: some View {
        
        // possible future experiment. see file
        let ps = PlatformSpecifics.forSizeClasses(
            vSizeClass: vClass!,
            hSizeClass: hClass!)
               
        GeometryReader { gr in
            TabView {

                PageView(pageType: PageType.superEllipse,
                         pageDesc: PageView.descriptions[0],
                         size: gr.size)
                    .tabItem {
                        SFSymbol.tab_1
                        Text("\(PageType.superEllipse.rawValue)" )
                    }
                
                PageView(pageType: PageType.circle,
                         pageDesc: PageView.descriptions[1],
                         size: gr.size)

                    .onAppear{ print("PageView.onAppear(PageType.CIRCLE)\n" +
                                     "         Platform { \(ps.name) }")}
                    .tabItem {
                        SFSymbol.tab_2
                        Text("\(PageType.circle.rawValue)")
                    }
                
                PageView(pageType: PageType.deltaWing,
                         pageDesc: PageView.descriptions[2],
                         size: gr.size)
                    .tabItem {
                        SFSymbol.tab_3
                        Text("\(PageType.deltaWing.rawValue)" )
                    }
                
                PageView(pageType: PageType.mutantMoth,
                         pageDesc: PageView.descriptions[3],
                         size: gr.size)
                    .tabItem {
                        SFSymbol.tab_4
                        Text("\(PageType.mutantMoth.rawValue)" )
                  }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    print( "%%%%%%% INACTIVE")
                }
                else if newPhase == .active {
                    print( "%%%%%%% ACTIVE")
                }
                else if newPhase == .background {
                    print( "%%%%%%% BACKGROUND")
                }
                else {
                    print( "%%%%%%% UNKNOWN SCENE PHASE !!!!!")
                }
            }
            .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                           stroke: .red,
                                           fill: .blue,
                                           buttonFace: .blue,
                                           buttonEdge: .black,
                                           allVertices: .green,
                                           vertex_0: .yellow)
            )
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
    @Published var vertex0Marker: Color
    
    init(background: Color,
         stroke: Color,
         fill: Color,
         buttonFace: Color,
         buttonEdge: Color,
         allVertices: Color,
         vertex_0: Color) {
        
        self.background = background
        self.stroke = stroke
        self.fill = fill
        self.buttonFace = buttonFace
        self.buttonEdge = buttonEdge
        self.allVertices = allVertices
        self.vertex0Marker = vertex_0
    }
}

struct Gray {
    static let light = Color.init(white: 0.8)
    static let dark = Color.init(white: 0.2)
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let s = CGSize(width: 500, height: 500)
        
        HStack {
            VStack {
                PageView(pageType: PageType.superEllipse,
                         pageDesc: PageView.descriptions[0],
                         size: s)
                    .environmentObject(ColorScheme(background: Gray.light,
                                                   stroke: .green,
                                                   fill: .orange,
                                                   buttonFace: .green,
                                                   buttonEdge: .white,
                                                   allVertices: .blue,
                                                   vertex_0: .green)
                    )
                                       
                PageView(pageType: PageType.circle,
                         pageDesc: PageView.descriptions[0],
                         size: s)
                    .environmentObject(ColorScheme(background: Gray.light,
                                                   stroke: .red,
                                                   fill: .blue,
                                                   buttonFace: .red,
                                                   buttonEdge: .white,
                                                   allVertices: .green,
                                                   vertex_0: .red)
                    )
            }
            .environmentObject(SELayersViewModel())
            .environmentObject(MiscOptionsModel())
            
            VStack {
                PageView(pageType: PageType.superEllipse,
                         pageDesc: PageView.descriptions[2],
                         size: s)
                    .environmentObject(ColorScheme(background: Gray.dark,
                                                   stroke: .blue,
                                                   fill: Color.orange,
                                                   buttonFace: .red,
                                                   buttonEdge: .black,
                                                   allVertices: .blue,
                                                   vertex_0: .red)
                    )

                PageView(pageType: PageType.circle,
                         pageDesc: PageView.descriptions[2],
                         size: s)
                    .environmentObject(ColorScheme(background: Gray.dark,
                                                   stroke: .white,
                                                   fill: Color.blue,
                                                   buttonFace: .green,
                                                   buttonEdge: .black,
                                                   allVertices: .orange,
                                                   vertex_0: .red)
                    )
                //                .tabItem {
                //                    SFSymbol.tab_1
                //                    Text("\(PageType.circle.rawValue)" )
                //                }
            }
            .environmentObject(SELayersViewModel())
            .environmentObject(MiscOptionsModel())
        }
    }
    
}
