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
    case zigZags
    case zigZag_markers
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
    @State var lastItemClicked = -1
    
    let sectionHeader_animation = Text("Animating layers")
    let sectionHeader_support = Text("Static support layers")
    let sectionHeader_control = Text("Computer, talk to me")
    
    var body: some View
    {
        List () {
                        
    // SHOW ALL/HIDE ALL CONTROLS
            Section(header: sectionHeader_control.padding(8)) {
                ForEach( listItems.filter{ $0.section == .control }, id: \.type ) { item in
                    
                    toggleCheckmarkIfTapped(item: item)
                }
            }
            .textCase(.lowercase) // also .Text.Case.lowercase, .lowercase & nil
            
    // ANIMATED LAYERS
            Section(header: sectionHeader_animation.padding(8)) {
                ForEach( listItems.filter{ $0.section == .animating }, id: \.type ) { item in
                    
                    toggleCheckmarkIfTapped(item: item)
                }
            }
            .textCase(.lowercase)
            
    // STATIC SUPPORT LAYERS
            Section(header: sectionHeader_support.padding(8)) {
                ForEach( listItems.filter{ $0.section == .support }, id: \.type ) { item in
                    
                    toggleCheckmarkIfTapped(item: item)
                }
            }
            .textCase(.lowercase)
        }
        .environment(\.defaultMinListRowHeight, 46) // 0 makes as tight as possible
    }
    
    func toggleCheckmarkIfTapped(item: SuperEllipseLayer) -> some View {
        LayerItemRow(layerItem: item)
            .onTapGesture {
                // existence of a tappedItem and subsquent closure means
                // SOMETHING WAS TAPPED AND THE WHOLE LIST DISPLAY NEED TO BE RECOMPUTED
                
                if let tappedItem = listItems.firstIndex (
                    where: { $0.type.rawValue == item.type.rawValue }) {
                    
                    // update @State -- DO WE NEED TO ???????
                    lastItemClicked = listItems[tappedItem].type.rawValue
                    
                    assert(lastItemClicked == tappedItem)
                    
                    listItems[tappedItem].visible.toggle()
                    
                    print("toggleCheckmarkIfTapped(): tappedItem: {\(tappedItem)}")
                    // `````````````````````````````````````````````````````````````
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
