//
//  SELayersSelection.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-20.
//

import SwiftUI

enum LayerType : Int {
    case blob_stroke
    case blob_originMarker
    case blob_markers
    case baseCurve
    case baseCurve_markers
    case normals
    case envelopeBounds
    case zigZagsPlusMarkers
    case showAll
    case hideAll
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

struct ExampleView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button("New Message") { print("new message")}
            Text("Reply").background(Color.gray)// { print("reply") }
            Text("Forward") //{ print("forward")}
        }
    }
}

struct LayerSelectionList: View {
    @Binding var listItems : [SuperEllipseLayer]
    
    let sectionHeader_animation = Text("animating layers")
    let sectionHeader_support = Text("static support layers")
    let sectionHeader_control = Text("convenience functions")
    
    var body: some View
    {
        List () {
            
            Section() {
                ForEach(1..<2) { _ in
                    Text("Experimenting w/ a List Header...")
                        .background(Color.orange)
                        .frame(height: 35)
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
            
    // SHOW ALL/HIDE ALL CONTROLS
            Section(header: sectionHeader_control.padding(8)) {
                let section : SectionType = .control
                let itemsInSection = listItems.filter{ $0.section == section }
                
                ForEach( itemsInSection, id: \.type ) { item in
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
                        // if we're hiding all, hide EVERYTHING
                        // then turn 'hide all' back on
                        if item.type == .hideAll {
                            showHideAllLayers(show: false)
                            listItems[LayerType.hideAll.rawValue].visible = true
                        }
                        // if we're showing all, show EVERYTHING
                        // then turn 'hide all' back off
                        else if item.type == .showAll {
                            showHideAllLayers(show: true)
                            listItems[LayerType.hideAll.rawValue].visible = false
                        }
                        break
                    case .animating, .support:
                        
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
