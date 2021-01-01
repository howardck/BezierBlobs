//
//  SELayersSelection.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-20.
//

import SwiftUI

enum LayerType : Int {
    case showAll
    case hideAll
    case blob
    case blob_markers
    case blob_originMarkers
    case baseCurve
    case baseCurve_markers
    case normals
    case envelopeBounds
    case zigZagsPlusMarkers
}

enum SectionType {
    case animating
    case support
    case control
}

struct SuperEllipseLayer {
    var type : LayerType
    var section: SectionType
    var name : String
    var visible = false
}

struct LayerSelectionList: View {
    @Binding var listItems : [SuperEllipseLayer]
    
    let sectionHeader_animation = Text("animating layers")
    let sectionHeader_support = Text("static support layers")
    let sectionHeader_control = Text("show/hide everything")
    
    var body: some View
    {
        List () {
                        
    // SHOW ALL/HIDE ALL CONTROLS
            Section(header: sectionHeader_control.padding(8)) {
                let section : SectionType = .control
                let itemsInSection = listItems.filter{ $0.section == section }
                
                ForEach( itemsInSection, id: \.type ) { item in
                    handleCheckmarksForTapped(item: item, in: section)
                }
            }
            .textCase(.lowercase)
            
    // ANIMATED LAYERS
            Section(header: sectionHeader_animation.padding(8)) {
                let section : SectionType = .animating
                let itemsInSection = listItems.filter{ $0.section == section }
                
                ForEach( itemsInSection, id: \.type ) { item in
                    handleCheckmarksForTapped(item: item, in: section)
                }
            }
            .textCase(.lowercase)
            
    // STATIC SUPPORT LAYERS
            Section(header: sectionHeader_support.padding(8)) {
                let section : SectionType = .support
                let itemsInSection = listItems.filter{ $0.section == section}
                
                ForEach(itemsInSection, id: \.type ) { item in
                    handleCheckmarksForTapped(item: item, in: section)
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
                    where: { $0.type.rawValue == item.type.rawValue }) {
                    
                    switch section {
                    case .control :
                        if item.type == .hideAll {
                            showHideAllLayers(show: false)
                            listItems[1].visible = true
                        }
                        else if item.type == .showAll {
                            showHideAllLayers(show: true)
                            listItems[1].visible = false
                        }
                        break
                    case .animating, .support:
                        listItems[0].visible = false
                        listItems[1].visible = false
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
