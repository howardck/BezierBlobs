//
//  SELayersSelection.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-20.
//

import SwiftUI

enum SectionType {
    case animatingBlobCurves
    case staticSupportCurves
    case commands
}

struct Layer {
    var type : LayerType_NEW
    var section: SectionType
    var visible = false
}

class LayerVisibilityModel : ObservableObject {
    
    @Published var layers : [Layer] = [
        .init(type: .blob_stroked, section: .animatingBlobCurves, visible: true),
        .init(type: .blob_filled, section: .animatingBlobCurves),
        .init(type: .blob_vertex_0_marker, section: .animatingBlobCurves, visible: true),
        .init(type: .blob_markers, section: .animatingBlobCurves),
        .init(type: .zigZags_with_markers, section: .animatingBlobCurves),
        
        .init(type: .baseCurve, section: .staticSupportCurves, visible: true),
        .init(type: .baseCurve_markers, section: .staticSupportCurves, visible: true),
        .init(type: .normals, section: .staticSupportCurves),
        .init(type: .envelopeBounds, section: .staticSupportCurves, visible: true),
        
        .init(type: .showAll, section: .commands, visible: false),
        .init(type: .hideAll, section: .commands, visible: false)
    ]
    
    func isVisible(layerWithType: LayerType_NEW) -> Bool {
        layers.filter{ $0.type == layerWithType && $0.visible }.count == 1
    }
}

enum LayerType_NEW : Int {
    case blob_stroked
    case blob_filled
    case blob_vertex_0_marker
    case blob_markers
    case baseCurve
    case baseCurve_markers
    case normals
    case envelopeBounds
    case zigZags_with_markers
    case showAll
    case hideAll
}


enum LayerType : Int {
    case blob_stroked
    case blob_filled
    case blob_vertex_0_marker
    case blob_markers
    case baseCurve
    case baseCurve_markers
    case normals
    case envelopeBounds
    case zigZags_with_markers
    case showAll
    case hideAll
}


struct SuperEllipseLayer {
    var type : LayerType
    var section: SectionType
    var name : String
    var visible = false
}

struct LayerVisibilitySelectionList: View {
    @Binding var listItems : [SuperEllipseLayer]
    
    let sectionHeader_animation = Text("animating blob layers")
    let sectionHeader_support = Text("static support layers")
    let sectionHeader_control = Text("commands")
    
    var body: some View
    {
        List {
            
//            Section() {
//                    Text("Experimenting w/ a List Header...")
//                        .background(Color.orange)
//                        .frame(height: 35)
//            }
//            .textCase(.lowercase)
            
    // ANIMATED LAYERS
            Section(header: sectionHeader_animation.padding(8)) {
                let s = SectionType.animatingBlobCurves
                let items = listItems.filter{ $0.section == s }
                
                ForEach(items, id: \.type ) { item in
                    handleCheckmarksForTapped(item: item, in: s)
                }
            }
            .textCase(.lowercase)
            
    // STATIC SUPPORT LAYERS
            Section(header: sectionHeader_support.padding(8)) {
                let s = SectionType.staticSupportCurves
                let items = listItems.filter{ $0.section == s }
                
                ForEach(items, id: \.type ) { item in
                    handleCheckmarksForTapped(item: item, in: s)
                }
            }
            .textCase(.lowercase)
            
    // SHOW ALL/HIDE ALL CONTROLS
            Section(header: sectionHeader_control.padding(8)) {
                let s = SectionType.commands
                let items = listItems.filter{ $0.section == s }
                
                ForEach(items, id: \.type ) { item in
                    handleCheckmarksForTapped(item: item, in: s)
                }
            }
            .textCase(.lowercase)
        }
        .environment(\.defaultMinListRowHeight, 46) // 0 == as tight as possible
    }
    
    func handleCheckmarksForTapped(item: SuperEllipseLayer,
                                   in section: SectionType) -> some View {
        LayerItemRow(layerItem: item)
            .onTapGesture {
                if let tappedItem = listItems.firstIndex (
                    where: { $0.type == item.type }) {
                    
                    switch section {
                    case .commands :
                        // if we're hiding all, hide EVERYTHING
                        // then turn 'hide all' back on
                        if item.type == .hideAll {
                            showHideAllLayers(show: false)
                            listItems[LayerType.hideAll.rawValue].visible = true
                        }
                        // if we're showing all, show EVERYTHING
                        // then turn 'hide all' off
                        else if item.type == .showAll {
                            showHideAllLayers(show: true)
                            listItems[LayerType.hideAll.rawValue].visible = false
                        }
                        break
                    case .animatingBlobCurves, .staticSupportCurves:
                        
                        listItems[LayerType.showAll.rawValue].visible = false
                        listItems[LayerType.hideAll.rawValue].visible = false
                        listItems[tappedItem].visible.toggle()
                    }
                }
            }
    }
    
    func showHideAllLayers(show: Bool) {
        for ix in 0..<listItems.count {
            listItems[ix].visible = show ? true : false
        }
    }
}

struct LayerItemRow : View {
    var layerItem : SuperEllipseLayer

    var body: some View {
        HStack {
            CheckBox(checked: layerItem.visible)
            Spacer()
            Text(layerItem.name)
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
