//
//  SELayersSelection.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-20.
//

import SwiftUI

struct LayersSelectionList: View {
    
    static let DEBUG_PRINT_SHOW_LAYER_VISIBILITY_FLAGS = true
    static let DEBUG_PRINT_LAYER_LIST_TAPPING = false

    @Binding var layers : [Layer]

    let sectionHeaderColoring = Color.green
    
    func printLayerVisibilityFlags() {
        _ = self.layers.map { layer in
            print("layer: {\(layer.type.rawValue)} visibility: {\(layer.visible)}")
        }
    }
    
    var body: some View
    {
        List {
            
            Section(header: Text("Animating Blob Layers")
                        .foregroundColor(sectionHeaderColoring)
                        .font(.headline)
                        .padding(8)) {
                
                rowsInSection(for: .animatingBlobCurves)
            }
            .textCase(.lowercase)
            
            .onAppear() {
                if Self.DEBUG_PRINT_SHOW_LAYER_VISIBILITY_FLAGS {
                    print("LayersSelectionList.onAppear{}:")
                    printLayerVisibilityFlags()
                }
            }
            
            Section(header: Text("Support Layers")
                        .foregroundColor(sectionHeaderColoring)
                        .font(.headline)
                        .padding(8)) {
                
                rowsInSection(for: .staticSupportCurves)
            }
            .textCase(.lowercase)
            
            Section(header: Text("Shortcuts")
                        .foregroundColor(sectionHeaderColoring)
                        .font(.headline)
                        .padding(8)) {

                rowsInSection(for: .commands)
            }
            .textCase(.lowercase)
        }
        .environment(\.defaultMinListRowHeight, 46) // 0 == as tight as possible
    }
    
    func rowsInSection(for section: SectionType) -> some View {
        let items = layers.filter { $0.section == section }
        return ForEach(items, id: \.type) { layer in
            
            LayerItemRow(layerItem: layer)
                .onTapGesture {
                   
                    if let tappedItemIndex = layers.firstIndex(where: {
                        $0.type == layer.type
                    }) {
                        if Self.DEBUG_PRINT_LAYER_LIST_TAPPING {
                            print("layerItem tapped: {\(layer.type)} section: {\(section)} index: {\(tappedItemIndex)}")
                        }
                                                
                        if layer.type == .hideAll {
                            showHideAllLayers(show: false)
                            layers[index(of: .hideAll)].visible = true
                        }
                        else if layer.type == .showAll {
                            showHideAllLayers(show: true)
                            layers[index(of: .hideAll)].visible = false
                        }
                        else {
                            layers[index(of: .showAll)].visible = false
                            layers[index(of: .hideAll)].visible = false
                            
                            layers[tappedItemIndex].visible.toggle()
                        }
                    }
                }
        }
    }
    
    func index(of type: LayerType) -> Int {
        let index = layers.firstIndex(
            where: {$0.type == type} )
        return index!
    }
    
    func showHideAllLayers(show: Bool) {
        for ix in 0..<layers.count {
            layers[ix].visible = show ? true : false
        }
    }
}

struct LayerItemRow : View {
    var layerItem : Layer

    var body: some View {
        HStack {
            CheckBox(checked: layerItem.visible)
            Spacer()
            Text(layerItem.type.rawValue)
                .frame(width: 310, height: 30, alignment: .leading)
        }
    }
}

//  Image(systemName: "checkmark.rectangle.fill")
//  Image(systemName: "checkmark.rectangle.portrait.fill")
//  Image(systemName: "checkmark.square.fill")
struct CheckBox : View {
    var checked: Bool
    var body: some View {
        ZStack {
            Image(systemName: "rectangle.portrait")
                .font(.title3).foregroundColor(.gray)
            if checked {
                Image(systemName: "checkmark.rectangle.portrait.fill")
                    .font(.title3) .foregroundColor(.green)
            }
        }
    }
}

//struct LayersSelectionList_Previews: PreviewProvider {
//    static var previews: some View {
//        SuperEllipseLayerStacksSelectionList()
//    }
//}
