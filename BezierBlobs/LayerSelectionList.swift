//
//  SELayersSelection.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-20.
//

import SwiftUI

enum LayerType : Int {
    case blob
    case blob_markers
    case blob_originMarkers
    case baseCurve
    case baseCurve_markers
    case normals
    case envelopeBounds
    case zigZags
    case zigZag_markers
}

enum SectionType {
    case animating
    case support
}

struct SuperEllipseLayer {
    var type : LayerType
    var section: SectionType
    var name : String
    var visible = false
}

struct LayerSelectionList: View {
    @Binding var listItems : [SuperEllipseLayer]
    
    let sectionHeader_Animation = Text("Animating layers")
    let sectionHeader_Support = Text("Static support layers")
    
    var body: some View
    {
        List () {
            Section(header: sectionHeader_Animation.padding(8)) {
                ForEach( listItems.filter{ $0.section == .animating }, id: \.type ) { item in
                    
                    toggleCheckmarkIfTapped(item: item)
                }
            }
            .textCase(.lowercase)
            
            Section(header: sectionHeader_Support.padding(8)) {
                ForEach( listItems.filter{ $0.section == .support }, id: \.type ) { item in
                    
                    toggleCheckmarkIfTapped(item: item)
                }
            }
            .textCase(.lowercase) // or .Text.Case.lowercase or .lowercase or nil
        }
        .environment(\.defaultMinListRowHeight, 46) // 0 makes as tight as possible
    }
    
    func toggleCheckmarkIfTapped(item: SuperEllipseLayer) -> some View {
        LayerItemRow(layerItem: item)
            .onTapGesture {
                if let tappedItem = listItems.firstIndex (
                    where: { $0.type.rawValue == item.type.rawValue }) {
                    listItems[tappedItem].visible.toggle()
                }
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
