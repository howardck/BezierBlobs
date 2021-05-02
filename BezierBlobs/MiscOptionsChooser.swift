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
    
    @Published var perturbationOptions : [PerturbationTypeOption] = [
        
        .init(type: .randomizedZigZags, isSelected: true),
        .init(type: .randomAnywhereInEnvelope, isSelected: false)
    ]
    
    func isSelected(optionType: OptionType) -> Bool {
        options.filter{
            $0.type == optionType && $0.isSelected }.count == 1
    }
    
    func isSelected(perturbationType: PerturbationType) -> Bool {
        perturbationOptions.filter{
            $0.type == perturbationType && $0.isSelected }.count == 1
    }
}

enum PerturbationType : String {
    case randomizedZigZags = "randomized alternating zig-zags"
    case randomAnywhereInEnvelope = "random anywhere in envelope"
}

struct PerturbationTypeOption {
    var type : PerturbationType
    var isSelected: Bool
}

struct PerturbationTypeRow : View {
    var perturbationOption : PerturbationTypeOption
    var body : some View {
        HStack {
            CheckBox(checked: perturbationOption.isSelected)
            Spacer()
            Text(perturbationOption.type.rawValue)
                .frame(width: 360, height: 0, alignment: .leading)
        }
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
    @Binding var perturbationOptions : [PerturbationTypeOption]
    
    var body: some View {
        let sectionHeaderTextColor = Color.init(white: 0.1)
        
        List {
            Section(header: Text("misc options")
                .foregroundColor(sectionHeaderTextColor)) {
                
                ForEach(options, id: \.type) { option in
                    OptionRow(option: option)
                        .onTapGesture {
                            if let tappedItem = options.firstIndex (
                                where: { $0.type == option.type} ) {
                                options[tappedItem].isSelected.toggle()
                            }
                        }
                }
            }
            
            Section(header: Text("perturbation type if random")
                .foregroundColor(sectionHeaderTextColor)) {

                PerturbationTypeRow(perturbationOption: PerturbationTypeOption(type: .randomizedZigZags,
                                                                          isSelected: false))
                PerturbationTypeRow(perturbationOption: PerturbationTypeOption(type: .randomAnywhereInEnvelope,
                                                                          isSelected: true))
//                    Text("1")
//                    Text("2")
//                    Text("3")
            }
            
            Section(header: Text("driving the tap-driven highway")
                        .foregroundColor(sectionHeaderTextColor)) {
                VStack {
                    bulletedTextItem(text: "tap screen to dismiss this dialog")
                    bulletedTextItem(text: "tap 1x to start animating")
                    bulletedTextItem(text: "tap 1x to stop animating")
                    bulletedTextItem(text: "tap 2x to revert to original shape")
                    bulletedTextItem(text: "rinse & repeat")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.defaultMinListRowHeight, 40)
    }
    
    func bulletedTextItem(text: String) -> some View {
        HStack {
            Image(systemName: "circle.fill")
                .scaleEffect(0.5)
                .foregroundColor(.green)
                //.foregroundColor(Color.init(white: 0.4))
            Spacer(minLength: 6)
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
