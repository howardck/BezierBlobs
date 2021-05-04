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
    
    @Published var smoothed = true
    
    @Published var options : [Option] = [

        //.init(type: .smoothed, isSelected: true),
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
    case randomizedZigZags = "alternating zig-zags"
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
    var isSelected: Bool
    var text : String
    var body: some View {
        HStack {
            CheckBox(checked: isSelected)
            Spacer()
            Text(text)
                .frame(width: 360, height: 0, alignment: .leading)
        }
    }
}

struct MiscOptionsChooser: View {
    
    @Binding var smoothed : Bool
    
    @Binding var options : [Option]
    @Binding var perturbationOptions : [PerturbationTypeOption]
    
    var body: some View {
        let sectionHeaderTextColor = Color.init(white: 0.1)
        
        List {
            
            Section(header: Text("miscellaneous")) {
                OptionRow(isSelected: smoothed, text: "smoothed")
                    .onTapGesture {
                        smoothed.toggle()
                    }
            }

            Section(header: Text("miscellaneous")
                .foregroundColor(sectionHeaderTextColor)) {
                
                ForEach(options, id: \.type) { option in
                    OptionRow(isSelected: option.isSelected, text: option.type.rawValue)
                        .onTapGesture {
                            if let tappedItem = options.firstIndex (
                                where: { $0.type == option.type} ) {
                                options[tappedItem].isSelected.toggle()
                            }
                        }
                }
            }
            
            Section(header: Text("perturbation type")
                .foregroundColor(sectionHeaderTextColor)) {

                PerturbationTypeRow(perturbationOption:
                                        PerturbationTypeOption(type: .randomizedZigZags,
                                                               isSelected: false))
                    .onTapGesture(count: 1) {
                        print("Tapped 'Perturbation: alternating zigZags'")
                        
                    }
                PerturbationTypeRow(perturbationOption:
                                        PerturbationTypeOption(type: .randomAnywhereInEnvelope,
                                                               isSelected: true))
                    .onTapGesture(count: 1) {
                        print("Tapped 'Perturbation: random anywhere in envelope'")
                    }
            }
            
            Section(header: Text("driving the tap-driven highway")
                        .foregroundColor(sectionHeaderTextColor)) {
                VStack {
                    bulletedTextItem(text: "tap screen to dismiss dialog.")
                    bulletedTextItem(text: "tap 1x to start animating.")
                    bulletedTextItem(text: "tap 1x to stop animating.")
                    bulletedTextItem(text: "tap 2x to revert to original shape.")
                    bulletedTextItem(text: "rinse & repeat.")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.defaultMinListRowHeight, 34)
    }
    
    func bulletedTextItem(text: String) -> some View {
        HStack(alignment: .center){
            Image(systemName: "diamond.fill")
                .scaleEffect(0.7)
                .foregroundColor(.yellow)
            Spacer(minLength: 4)
            Text(text)
                .frame(width: 360, height: 34, alignment: .leading)
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
