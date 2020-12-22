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
    case zigZags
    case zigZag_markers
    case envelopeBounds
}

struct SuperEllipseLayer  {
    var type : LayerType
    var name : String
    var isVisible = false
}

struct SuperEllipseLayerSelectionList: View {
    @Binding var listItems : [SuperEllipseLayer]

    var body: some View {
        List( listItems, id: \.type ) { item in
            LayerItemRow(layerItem: item)
                .onAppear {print(".onAppear{}: \"\(item.name)\"")}
                .onTapGesture {
                    print("LayersList: tapped on item {\"\(item.name)\"} type: {\(item.type.rawValue)}")
                    if let tappedItem = listItems.firstIndex(where: { $0.type.rawValue == item.type.rawValue }) {
                        listItems[tappedItem].isVisible.toggle()
                    }
                }
        }
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
