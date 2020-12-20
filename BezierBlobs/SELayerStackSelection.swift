//
//  SELayersSelection.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-20.
//

import SwiftUI

struct SuperEllipseLayerItem : Identifiable {
    let id = UUID()
    var name : String
    var isSelected = false
}

struct SuperEllipseLayerStacksSelectionList: View {
    @State var listItems : [SuperEllipseLayerItem] = [
        .init(name: "animatingBlob"),
        .init(name: "normals"),
        .init(name: "baseCurve"),
        .init(name: "zigZags"),
        .init(name: "envelope bounds"),
        .init(name: "baseCurve (markers)"),
        .init(name: "animatingBlob (markers)"),
        .init(name: "animatingBlob (point zero marker)")
    ]
    var body: some View {
        List {
            ForEach(listItems) { item in
                LayerItemRow(layerItem: item)
                    .onTapGesture {
                        if let tappedItem = listItems.firstIndex(where: { $0.id == item.id }) {
                            listItems[tappedItem].isSelected.toggle()
                        }
                    }
            }
        }
        .environment(\.defaultMinListRowHeight, 46)
    }
}

struct LayerItemRow : View {
    var layerItem : SuperEllipseLayerItem

    var body: some View {
        HStack {
            CheckBox(checked: layerItem.isSelected)
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

struct LayersSelectionList_Previews: PreviewProvider {
    static var previews: some View {
        SuperEllipseLayerStacksSelectionList()
    }
}
