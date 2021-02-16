//
//  MiscOptionsChooserList.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-11.
//

import Combine
import SwiftUI

enum OptionType : String {
    case smoothed = "smoothed"
    case randomPerturbations = "random perturbations"
}

struct Option {
    var type : OptionType
    var isSelected : Bool
}

class Options: ObservableObject {
    
    @Published var options : [Option] = [

        .init(type: .smoothed, isSelected: true),
        .init(type: .randomPerturbations, isSelected: false)
    ]
}

struct OptionRow : View {
    var option : Option
    var body: some View {
        HStack {
            CheckBox(checked: option.isSelected)
            Spacer()
            Text(option.type.rawValue)
                .frame(width: 320, height: 0, alignment: .leading)
        }
    }
}

struct MoreOptionsChooserList: View {
    
    @Binding var options : [Option]
    
    var body: some View {
        let sectionHeaderTextColor = Color.init(white: 0.1)
        
        List {
            Section(header: Text("more options").textCase(.uppercase)
                .foregroundColor(sectionHeaderTextColor)) {
                
                ForEach(options, id: \.type) { option in
                    OptionRow(option: option)
                        .onTapGesture {
                            print("tapped option item!")
                        }
                }
            }
            .textCase(.lowercase)
        }
//        .listStyle(GroupedListStyle())
        .listStyle(InsetGroupedListStyle())
        .environment(\.defaultMinListRowHeight, 38)
    }
}

//struct MiscOptionsSelectionList_Previews: PreviewProvider {
//    static var previews: some View {
//        MiscOptionsChooserList()
//    }
//}
