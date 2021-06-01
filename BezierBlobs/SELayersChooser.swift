//
//  LayersSelectionList.swift -- BezierBlobs
//  Created by Howard Katz on 2020-12-20


import SwiftUI

struct SELayersChooser: View {
    
    static let DEBUG_PRINT_SHOW_LAYER_VISIBILITY = false
    static let DEBUG_PRINT_LAYER_LIST_TAPPING = false
    
    func DEBUG_printLayerVisibilityFlags() {
        _ = self.layers.map { layer in
            print("layer [.\(layer.type.rawValue)] visible: {\(layer.visible)}")
        }
    }
 
    @Binding var layers : [Layer]
    let sectionHeaderTextColor = Color.init(white: 0.1)
    
    var body: some View
    {
        List {
            Section(header: Text("Animating Blob Layers").textCase(.uppercase)) {
                rows(in: .animatingBlobCurves)
            }
            .textCase(.lowercase)

            Section(header: Text("Support Layers").textCase(.uppercase)) {
                rows(in: .staticSupportCurves)
            }
            .textCase(.lowercase)
            
            Section(header: Text("Shortcuts").textCase(.uppercase)) {
                rows(in: .shortcuts)
            }
            .textCase(.lowercase)
        }
        .onAppear() {
            if Self.DEBUG_PRINT_SHOW_LAYER_VISIBILITY {
                print("LayersSelectionList.onAppear{} ........")
                DEBUG_printLayerVisibilityFlags()
            }
        }
        .listStyle(InsetGroupedListStyle())
        // was initially 34
        .environment(\.defaultMinListRowHeight, 40)
    }
    
    func rows(in section: SectionType) -> some View {
        
        let items = layers.filter { $0.section == section }
        return ForEach(items, id: \.type) { layer in
            
            LabeledCheckboxRow(isSelected: layer.visible,
                               text: layer.type.rawValue)
                .frame(width: 314, height: 10, alignment: .leading)
                .onTapGesture {
                   
                    if let tappedItemIndex = layers.firstIndex(
                        where: { $0.type == layer.type })
                    {
                        if Self.DEBUG_PRINT_LAYER_LIST_TAPPING {
                            print("tapped layerItem [\(tappedItemIndex)]: {LayerType.\(layer.type)} {Section.\(section)}")
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
        let index = layers.firstIndex(where: { $0.type == type })
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
                .frame(width: 314, height: 10, alignment: .leading)
        }
    }
}

//struct LayersSelectionList_Previews: PreviewProvider {
//    static var previews: some View {
//        SuperEllipseLayerStacksSelectionList()
//    }
//}
