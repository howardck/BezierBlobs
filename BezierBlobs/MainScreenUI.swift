//
//  ScreenUI.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-25.
//

import SwiftUI

struct MainScreenUI: View {
    
    static let TWO_BUTTON_PADDING : CGFloat = 70
    static let TWO_BUTTON_PANEL_ON_LEFT = true
    
    @Binding var showLayersList: Bool
    @Binding var showMiscOptionsList : Bool
    var deviceType: PlatformSpecifics.SizeClass
    
    @EnvironmentObject var layers : SELayersViewModel
    @EnvironmentObject var options : MiscOptionsModel
    
    var body: some View {
        
            VStack {
                Spacer()
                if showLayersList {
                    // ------------------------------------
                    let s = CGSize(width: 280, height: 560)
                    // ------------------------------------
                    HStack {
                        
                        if !MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                            Spacer()
                        }
                        
                        ZStack {
                            SELayersChooser(layers: $layers.layers)
                            BezelFrame(color: .orange, size: s)
                        }
                        .frame(width: s.width, height: s.height)
                        .padding(MainScreenUI.TWO_BUTTON_PADDING)
                        
                        if MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                            Spacer()
                        }

                    }
                }
                else if showMiscOptionsList {
                    // these numbers work for my iPhone Xs
                    // ------------------------------------
                    let s = CGSize(width: 340, height: 490)
                    // ------------------------------------
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
                        .padding(MainScreenUI.TWO_BUTTON_PADDING)
                        
                        if MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                            Spacer()
                        }
                    }
                }
                else {
                    let s = CGSize(width: 220, height: 130)
                    HStack {
                        if !MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                            Spacer()
                        }
                        
                        TwoButtonPanel(showLayersList: $showLayersList,
                                       showMiscOptionsList: $showMiscOptionsList,
                                       deviceType: deviceType)
                            .frame(width: s.width)
                            .padding(MainScreenUI.TWO_BUTTON_PADDING)
                        
                        if MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                            Spacer()
                        }
                    }
                }
            }
    }
}

/*
Previews ERROR MESSAGE:
 
"BezierBlobs preview crashed due to missing environment of type: ColorScheme. To resolve this add `.environmentObject(ColorScheme(...))` to the appropriate preview."
 
HOW TO DO THIS ??
*/

struct ScreenUI_Previews: PreviewProvider {
    @State static var showLayersList = false
    @State static var showMiscOptionsList = false

    @EnvironmentObject var layers : SELayersViewModel
    @EnvironmentObject var options : MiscOptionsModel

    static var previews: some View {
        
        VStack {
            let s = CGSize(width: 300, height: 0)
            
            Spacer()
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.red)
                .padding(MainScreenUI.TWO_BUTTON_PADDING)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: Color.init(white: 0.1),
                                               buttonEdge: .orange,
                                               allVertices: .green,
                                               evenNumberedVertices: .red,
                                               vertex_0: .yellow,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.red)
                .padding(MainScreenUI.TWO_BUTTON_PADDING)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: Color.init(white: 0.1),
                                               buttonEdge: .white,
                                               allVertices: .green,
                                               evenNumberedVertices: .red,
                                               vertex_0: .yellow,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.red)
                .padding(MainScreenUI.TWO_BUTTON_PADDING)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: .red,
                                               buttonEdge: .yellow,
                                               allVertices: .green,
                                               evenNumberedVertices: .red,
                                               vertex_0: .yellow,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.red)
                .padding(MainScreenUI.TWO_BUTTON_PADDING)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: Color(UIColor.red),
                                               buttonEdge: .yellow,
                                               allVertices: .green,
                                               evenNumberedVertices: .red,
                                               vertex_0: .yellow,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
            
            TwoButtonPanel(showLayersList: $showLayersList,
                           showMiscOptionsList: $showMiscOptionsList,
                           deviceType: .regular)
                .frame(width: s.width)
                .border(Color.red)
                .padding(MainScreenUI.TWO_BUTTON_PADDING)
                .environmentObject(ColorScheme(background: Color.init(white: 0.4),
                                               stroke: .orange,
                                               fill: .blue,
                                               buttonFace: Color.init(white: 0.1),
                                               buttonEdge: .red,
                                               allVertices: .green,
                                               evenNumberedVertices: .red,
                                               vertex_0: .yellow,
                                               offsetMarkers: .black,
                                               baseCurveMarkers: .white))
            
            Spacer()
        }
        .frame(width: 400, height: 800)
        .background(Color.gray)
    }
}
