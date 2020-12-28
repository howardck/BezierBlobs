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
    case ancillary
}

struct SuperEllipseLayer : Identifiable {
    var type : LayerType
    var id : LayerType
    var animationType: AnimationType
    var name : String
    var isVisible = false
}

struct SELayerSelectionList: View {
    @Binding var listItems : [SuperEllipseLayer]

    var body: some View
    {
//        List( listItems, id: \.type ) { item in
        List( listItems ) { item in
            LayerItemRow(layerItem: item)
                .onAppear { print(".onAppear{}: \"\(item.name)\"") }
                .onTapGesture {
                    print("LayerList: tapped on item {\"\(item.name)\"} type: {\(item.type.rawValue)}")

                    if let tappedItem = listItems.firstIndex(where:
                                                                { $0.type.rawValue == item.type.rawValue })
                    {
                        listItems[tappedItem].isVisible.toggle()
                    }
                }
        }
        .environment(\.defaultMinListRowHeight, 46)
    }
}
        
        
//        List {
//            Section(header: Text("Animating layers").padding(8)) {
//                ForEach(listItems.filter{$0.animationType == .animating}, id: \.type) { item in
//                    LayerItemRow(layerItem: item)
//                }
//            }
//            .textCase(.lowercase)
//            Section(header: Text("Static support layers").padding(8)) {
//                ForEach(listItems.filter{$0.animationType == .ancillary}, id: \.type) { item in
//                    LayerItemRow(layerItem: item)
//                }
//            }
//            .textCase(.lowercase) // or .Text.Case.lowercase or .lowercase or nil
//        }
//        // adding .environment(... : 0) makes spacing as tight as possible
//        .environment(\.defaultMinListRowHeight, 0)
//    }
//}

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
