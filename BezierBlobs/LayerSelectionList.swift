//
//  SELayersSelection.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-20.
//

import SwiftUI

enum LayerType : Int {
    case animatingBlob
    case animatingBlob_markers
    case animatingBlob_originMarkers
    case baseCurve
    case baseCurve_markers
    case normals
    case envelopeBounds
    case zigZags
    case zigZag_markers
}

enum AnimationType {
    case animating
    case support
}

struct SuperEllipseLayer : Identifiable {
    var type : LayerType
    var id : LayerType
    var animationType: AnimationType
    var name : String
    var isVisible = false
    
    // trying to simplify the List() selection mechanism.
    // this doesn't work with ForEach(listItems) ...
    // the compiler complains that 'item' is an immmutable 'let' constant
    mutating func toggleVisibility() {
        isVisible.toggle()
    }
}

struct LayerSelectionList: View {
    @Binding var listItems : [SuperEllipseLayer]
    
    var body: some View
    {
        List () { // item in
            Section(header: Text("Animating layers").padding(8)) {
                ForEach(listItems.filter{$0.animationType == .animating}, id: \.type)
                { item in
                    LayerItemRow(layerItem: item)
                        .onTapGesture {
                            if let tapped = listItems.firstIndex(
                                where: { $0.type.rawValue == item.type.rawValue })
                            {
                                listItems[tapped].isVisible.toggle()
                            }
                        }
                }
            }
            .textCase(.lowercase)
            
            Section(header: Text("Static support layers").padding(8)) {
                ForEach(listItems.filter{$0.animationType == .support}, id: \.type)
                { item in
                    LayerItemRow(layerItem: item)
                        .onTapGesture {
                            print("item = {\(item.name)}")
                            // no-go -- see struct SuperEllipseLayer {} above
                            //item.toggleVisibility()
                            
                            if let tappedItem = listItems.firstIndex(
                                where: { $0.type.rawValue == item.type.rawValue })
                            {
                                listItems[tappedItem].isVisible.toggle()
                            }
                        }
                }
            }
            .textCase(.lowercase) // or .Text.Case.lowercase or .lowercase or nil
        }
        // .environment(default... : 0) makes spacing as tight as possible
        .environment(\.defaultMinListRowHeight, 46)
    }
}

struct LayerItemRow : View {
    var layerItem : SuperEllipseLayer

    var body: some View {
        HStack {
            CheckBox(checked: layerItem.isVisible)
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
