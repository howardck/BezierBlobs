//
//  MiscOptionsChooser.swift
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

class MiscOptionsModel: ObservableObject {
    
    @Published var options : [Option] = [

        .init(type: .smoothed, isSelected: true),
        .init(type: .randomPerturbations, isSelected: true)
    ]
    
    func isSelected(optionType: OptionType) -> Bool {
        options.filter{ $0.type == optionType && $0.isSelected }.count == 1
    }
}

struct OptionRow : View {
    var option : Option
    var body: some View {
        HStack {
            CheckBox(checked: option.isSelected)
            Spacer()
            Text(option.type.rawValue)
                .frame(width: 360, height: 0, alignment: .leading)
        }
    }
}

struct MiscOptionsChooser: View {
    
    @Binding var options : [Option]
    
    var body: some View {
        let sectionHeaderTextColor = Color.init(white: 0.1)
        
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
            Section(header: Text("driving the tap-driven highway").textCase(.uppercase)
                        .foregroundColor(sectionHeaderTextColor)) {
                VStack {
                    bulletedTextItem(text: "tap main screen to dismiss this dialog")
                    bulletedTextItem(text: "tap x1 to start animating")
                    bulletedTextItem(text: "tap x1 to stop animating")
                    bulletedTextItem(text: "tap x2 to revert to original shape")
                    bulletedTextItem(text: "rinse and repeat")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.defaultMinListRowHeight, 40)
    }
    
    func bulletedTextItem(text: String) -> some View {
        HStack {
            Image(systemName: "circle.fill")
                .scaleEffect(0.6)
                .foregroundColor(Color.init(white: 0.4))
            Spacer(minLength: 2)
            Text(text)
                .foregroundColor(.black)
                .frame(width: 360, height: 30, alignment: .leading)
        }
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
