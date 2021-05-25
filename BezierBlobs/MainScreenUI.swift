//
//  ScreenUI.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-25.
//

import SwiftUI

struct MainScreenUI: View {
    
    @Binding var showLayersList: Bool
    @Binding var showMiscOptionsList : Bool
    
    @EnvironmentObject var layers : SELayersViewModel
    @EnvironmentObject var options : MiscOptionsModel
    
    var body: some View {
        
            VStack {
                Spacer()
                if showLayersList {
                    let s = CGSize(width: 260, height: 600)
                    HStack {
                        ZStack {
                            SELayersChooser(layers: $layers.layers)
                                .frame(width: s.width, height: s.height)
                            BezelFrame(color: .orange, size: s)
                        }
                        .padding(30)
                        Spacer()
                    }
                }
                else if showMiscOptionsList {
                    // ------------------------------------
                    let s = CGSize(width: 350, height: 450)
                    // ------------------------------------
                    HStack {
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
                        .padding(30)
                        Spacer()
                    }
                }
                else {
                    let s = CGSize(width: 266, height: 130)
                    HStack {
                        TwoButtonPanel(showLayersList: $showLayersList,
                                       showMiscOptionsList: $showMiscOptionsList)
                            .frame(width: s.width)
                            .padding(EdgeInsets(top: 0, leading: 30, bottom: 50, trailing: 0))
                        Spacer()
                    }
                }
            }
        
    }
}

//struct ScreenUI_Previews: PreviewProvider {
//    static var previews: some View {
//        ScreenUI()
//    }
//}
