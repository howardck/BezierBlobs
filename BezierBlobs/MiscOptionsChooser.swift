//
//  MiscOptionsChooser.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-11.
//

import Combine
import SwiftUI

enum ZigZagAnimationType: String {
    case fixed = "fixed"
    case snapTo = "snap to"
    case animated = "animated"
}

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
        .init(type: .randomPerturbations, isSelected: true)
    ]
    
    func isSelected(optionWithType: OptionType) -> Bool {
        options.filter{ $0.type == optionWithType && $0.isSelected }.count == 1
    }
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

struct MiscOptionsChooserList: View {
    
    @Binding var options : [Option]
    
    var body: some View {
        let sectionHeaderTextColor = Color.init(white: 0.1)
//        let sectionHeaderTextColor = Color.blue

        List {
            Section(header: Text("misc options").textCase(.uppercase)
                .foregroundColor(sectionHeaderTextColor)) {
                
                ForEach(options, id: \.type) { option in
                    OptionRow(option: option)
                        .onTapGesture {
                            if let tappedItem = options.firstIndex (
                                where: {$0.type == option.type})
                            {
                                options[tappedItem].isSelected.toggle()
                            }
                        }
                }
            }
            
            Section(header: Text("a tap-driven interface").textCase(.uppercase)
                        .foregroundColor(sectionHeaderTextColor)) {
                VStack(alignment: .leading) {
                    Text(Image(systemName: "checkmark.rectangle.portrait.fill")) + Text(" hello")
                    Text(Image(systemName: "checkmark.rectangle.portrait.fill")) + Text(" goodbye")
                    Text(Image(systemName: "checkmark.rectangle.portrait.fill")) + Text(" & a 3rd time!")
                }
                .frame(alignment: .leading)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.defaultMinListRowHeight, 40)
    }
}

struct MiscOptionsChooserList_Previews: PreviewProvider {
    static var previews: some View {

        Text("SELECTED")
            .font(.custom("courier", size: 42))
            .fontWeight(.heavy)
            .foregroundColor(.green)
    }
}
