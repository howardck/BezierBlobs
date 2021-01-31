//
//  SELayersSelection.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-20.
//

import SwiftUI

enum LayerType : String {
    case blob_stroked = "stroked"
    case blob_filled = "filled"
    case blob_vertex_0_marker = "vertex[0] marker"
    case blob_markers = "all vertex markers"
    
    case baseCurve = "baseCurve"
    case baseCurve_markers = "baseCurve markers"
    case normals = "normals"
    case envelopeBounds = "envelope Bounds"
    case zigZags_with_markers = "zigZags + markers"
    
    case showAll = "show All"
    case hideAll = "hide All"
}

enum SectionType {
    case animatingBlobCurves
    case staticSupportCurves
    case commands
}

struct Layer {
    var type : LayerType
    var section: SectionType
    var visible = false
}

class LayerVisibilityModel : ObservableObject {
    
    @Published var layers : [Layer] = [
        .init(type: .blob_stroked, section: .animatingBlobCurves, visible: true),
        .init(type: .blob_filled, section: .animatingBlobCurves, visible: true),
        .init(type: .blob_vertex_0_marker, section: .animatingBlobCurves, visible: true),
        .init(type: .blob_markers, section: .animatingBlobCurves),
    // -------------------------------------------------------------------------------
        .init(type: .baseCurve, section: .staticSupportCurves),
        .init(type: .baseCurve_markers, section: .staticSupportCurves),
        .init(type: .normals, section: .staticSupportCurves),
        .init(type: .envelopeBounds, section: .staticSupportCurves),
        .init(type: .zigZags_with_markers, section: .staticSupportCurves),
    // -------------------------------------------------------------------------------
        .init(type: .showAll, section: .commands),
        .init(type: .hideAll, section: .commands)
    ]
    
    func isVisible(layerWithType: LayerType) -> Bool {
        layers.filter{ $0.type == layerWithType && $0.visible }.count == 1
    }
    
    func index(of layerWithType: LayerType) -> Int {
        layers.firstIndex ( where: { $0.type == layerWithType })!
    }
}


//enum LayerType : Int {
//    case blob_stroked
//    case blob_filled
//    case blob_vertex_0_marker
//    case blob_markers
//    case baseCurve
//    case baseCurve_markers
//    case normals
//    case envelopeBounds
//    case zigZags_with_markers
//    case showAll
//    case hideAll
//}

//struct SuperEllipseLayer {
//    var type : LayerType
//    var section: SectionType
//    var name : String
//    var visible = false
//}

struct LayerVisibilitySelectionList: View {
    
    @Binding var layers : [Layer]
    //@Binding var listItems : [SuperEllipseLayer]
    
    var body: some View
    {
        List {
            
            Section(header: Text("Animating Blob Layers")
                        .foregroundColor(.blue)
                        .font(.headline)
                        .padding(8)) {
                
                rows(in: .animatingBlobCurves)
            }
            .textCase(.lowercase)
            
            Section(header: Text("Static Support Layers")
                        .font(.headline)
                        .padding(8)) {
                
                rows(in: .staticSupportCurves)
            }
            .textCase(.lowercase)
            
            Section(header: Text("commands")
                        .font(.headline)
                        .padding(8)) {

                    rows(in: .commands)
            }
            .textCase(.lowercase)
        }
        .environment(\.defaultMinListRowHeight, 46) // 0 == as tight as possible
    }
    
    func rows(in section: SectionType) -> some View {
        let items = layers.filter { $0.section == section }
        return ForEach(items, id: \.type) { layer in
            
            LayerItemRow(layerItem: layer)
                .onTapGesture {
                   
                    if let tappedItemIndex = layers.firstIndex(where: {
                        $0.type == layer.type
                    }) {
                        print("layerItem tapped: {\(layer.type)} section: {\(section)} index: {\(tappedItemIndex)}")
                                                
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
    
    func handleCheckmarksForTapped(item: Layer,
                                   in section: SectionType) -> some View {
        LayerItemRow(layerItem: item)
            .onTapGesture {
                if let tappedItem = layers.firstIndex (
                    where: { $0.type == item.type }) {
                    
                    print("\(item.type.rawValue)")
                    
//                    switch section {
//                    case .commands :
//                        // if we're hiding all, hide EVERYTHING
//                        // then turn 'hide all' back on
//                        if item.type == .hideAll {
//                            showHideAllLayers(show: false)
//                            layers[.hideAll.rawValue].visible = true
//                        }
//                        // if we're showing all, show EVERYTHING then turn 'hide all' off
//                        else if item.type == .showAll {
//                            showHideAllLayers(show: true)
//                            layers[LayerType.hideAll.rawValue].visible = false
//                        }
//                        break
//                    case .animatingBlobCurves, .staticSupportCurves:
//
//                        layer(for type: .showAll)!.visible = false
//                        layers[LayerType.showAll.rawValue].visible = false
//                        layers[LayerType.hideAll.rawValue].visible = false
//                        layers[tappedItem].visible.toggle()
//                    }
                    
                    
                }
            }
    }
    
//    func showHideAllLayers(show: Bool) {
//        for ix in 0..<layers.count {
//            layers[ix].visible = show ? true : false
//        }
//    }
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
