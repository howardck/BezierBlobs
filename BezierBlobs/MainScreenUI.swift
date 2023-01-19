//
//  MainScreenUI.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-25.
//

import SwiftUI

struct MainScreenUI: View {
    
    static let TWO_BUTTON_PANEL_ON_LEFT = true
    
    static let TWO_BUTTON_PADDING : CGFloat = 60
    static let TWO_BUTTON_PADDING_COMPACT : CGFloat = 30
    
    static let FULL_BUTTON_PANEL_WIDTH : CGFloat = 200
    static let FULL_BUTTON_PANEL_WIDTH_COMPACT : CGFloat = 180
    
    static let LAYERS_LIST_CGSIZE = CGSize(width: 310, height: 610)
    static let OPTIONS_LIST_CGSIZE = CGSize(width: 330, height: 545)
    
    @Binding var showLayersList: Bool
    @Binding var showMiscOptionsList : Bool
    var deviceType: PlatformSpecifics.SizeClass
    
    @EnvironmentObject var layers : SELayersModel
    @EnvironmentObject var options : MiscOptionsModel
    
    var body: some View {
        
        VStack {
            Spacer()
            
            if showLayersList {
                // ----------------------------
                let s = Self.LAYERS_LIST_CGSIZE
                // ----------------------------
                HStack {
                    if !MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                        Spacer()
                    }
                    ZStack {
                        SELayersChooser(layers: $layers.layers)
                        BezelFrame(color: .orange, size: s)
                    }
                    .frame(width: s.width, height: s.height)
                    .padding(deviceType == .regular ?
                                MainScreenUI.TWO_BUTTON_PADDING :
                                MainScreenUI.TWO_BUTTON_PADDING_COMPACT )
                    
                    if MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                        Spacer()
                    }
                }
            }
            else if showMiscOptionsList {
                // -----------------------------
                let s = Self.OPTIONS_LIST_CGSIZE
                // -----------------------------
                HStack {
                    if !MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                        Spacer()
                    }
                    ZStack {
                        MiscOptionsChooser(smoothed: $options.smoothed,
                                           selection: $options.currPerturbStrategy)
                            .frame(width: s.width, height: s.height)
                        
                        BezelFrame(color: .orange, size: s)
                    }
                    .padding(deviceType == .regular ?
                                MainScreenUI.TWO_BUTTON_PADDING :
                                MainScreenUI.TWO_BUTTON_PADDING_COMPACT )
                    
                    if MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                        Spacer()
                    }
                }
            }
            else {
                HStack {
                    if !MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                        Spacer()
                    }
                    TwoButtonPanel(showLayersList: $showLayersList,
                                   showMiscOptionsList: $showMiscOptionsList,
                                   deviceType: deviceType)
                        .frame(width: deviceType == .regular ?
                                    MainScreenUI.FULL_BUTTON_PANEL_WIDTH :
                                    MainScreenUI.FULL_BUTTON_PANEL_WIDTH_COMPACT)
                        .padding(deviceType == .regular ?
                                    MainScreenUI.TWO_BUTTON_PADDING :
                                    MainScreenUI.TWO_BUTTON_PADDING_COMPACT)
                    
                    if MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ScreenUI_Previews: PreviewProvider {
    @State static var showLayersList = false
    @State static var showMiscOptionsList = false

    @EnvironmentObject var layers : SELayersModel
    @EnvironmentObject var options : MiscOptionsModel
    
    // not sure why we're getting irregular vertical spacing ... 

    static var previews: some View {
        
        VStack {
            let s = CGSize(width: 200, height: 100)
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.orange)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: Color.init(white: 0.1),
                                               buttonEdge: .orange,
                                               evenNumberedVertices: .red,
                                               oddNumberedVertices: .green,
                                               vertex0Marker: .yellow,
                                               orbitalVertexOuter: .purple,
                                               orbitalVertexInner: .white,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.white)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: Color.init(white: 0.1),
                                               buttonEdge: .white,
                                               evenNumberedVertices: .red,
                                               oddNumberedVertices: .green,
                                               vertex0Marker: .yellow,
                                               orbitalVertexOuter: .purple,
                                               orbitalVertexInner: .white,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.yellow)
                .padding(MainScreenUI.TWO_BUTTON_PADDING)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: .red,
                                               buttonEdge: .yellow,
                                               evenNumberedVertices: .red,
                                               oddNumberedVertices: .green,
                                               vertex0Marker: .yellow,
                                               orbitalVertexOuter: .purple,
                                               orbitalVertexInner: .white,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.yellow)
                .padding(MainScreenUI.TWO_BUTTON_PADDING)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: Color(UIColor.red),
                                               buttonEdge: .yellow,
                                               evenNumberedVertices: .red,
                                               oddNumberedVertices: .green,
                                               vertex0Marker: .yellow,
                                               orbitalVertexOuter: .purple,
                                               orbitalVertexInner: .white,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.red)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: Color.init(white: 0.1),
                                               buttonEdge: .red,
                                               evenNumberedVertices: .red,
                                               oddNumberedVertices: .green,
                                               vertex0Marker: .yellow,
                                               orbitalVertexOuter: .purple,
                                               orbitalVertexInner: .white,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
        }
    }
}
