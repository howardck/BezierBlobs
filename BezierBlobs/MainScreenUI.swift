//
//  ScreenUI.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-25.
//

import SwiftUI

struct MainScreenUI: View {
    
    static let TWO_BUTTON_PADDING : CGFloat = 80
    static let TWO_BUTTON_PANEL_ON_LEFT = false
    
    @Binding var showLayersList: Bool
    @Binding var showMiscOptionsList : Bool
    
    @EnvironmentObject var layers : SELayersViewModel
    @EnvironmentObject var options : MiscOptionsModel
    @EnvironmentObject var colorScheme : ColorScheme
    
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
                            SELayerGroupsChooser(layers: $layers.layers)
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
                    // ------------------------------------
                    let s = CGSize(width: 330, height: 500)
                    // ------------------------------------
                    HStack {
                        
                        if !MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT {
                            Spacer()
                        }
                        
                        ZStack {
                            MiscOptionsChooser(
                                smoothed: $options.smoothed,
                                // OLD STYLE: display the options out of an array
                                // perturbationOptions: $options.perturbationOptions,
                                
                                // NEW STYLE: the ForEach knows all the options
                                // from a static .allCases, so only the curr
                                // value of the enum is needed to show selection
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
                                       showMiscOptionsList: $showMiscOptionsList)
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

//struct ScreenUI_Previews: PreviewProvider {
//    @State static var showLayersList = false
//    @State static var showMiscOptionsList = false
//
//    @EnvironmentObject var layers : SELayersViewModel
//    @EnvironmentObject var options : MiscOptionsModel
//
//    @EnvironmentObject var colorScheme : ColorScheme
//
//    static var previews: some View {
//
//        MainScreenUI(showLayersList : $showLayersList,
//                     showMiscOptionsList: $showMiscOptionsList)
//    }
//}
