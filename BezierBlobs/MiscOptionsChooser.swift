//
//  MiscOptionsChooser.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-11.
//

import Combine
import SwiftUI

class MiscOptionsModel: ObservableObject {
    
    @Published var smoothed = true
    @Published var currPerturbationOption = PerturbationType.randomizedZigZags
    @Published var perturbationOptions : [PerturbationTypeOption] = [
        
        .init(type: .staticZigZags, isSelected: false),
        .init(type: .randomizedZigZags, isSelected: true),
        .init(type: .randomAnywhereInEnvelope, isSelected: false)
    ]

    func isSelected(perturbationType: PerturbationType) -> Bool {
        perturbationOptions.filter{
            $0.type == perturbationType && $0.isSelected }.count == 1
    }
}

enum PerturbationType : String {
    case staticZigZags = "static zig-zags"
    case randomizedZigZags = "randomized zig-zags"
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
            
            Section(header: Text("perturbation type")
                .foregroundColor(sectionHeaderTextColor)) {
                
                ForEach(perturbationOptions, id: \.type) { perturbationOption in
                    PerturbationTypeRow(perturbationOption: perturbationOption)
                        // quick & dirty radio buttons
                        .onTapGesture {
                            if let tappedItem = perturbationOptions.firstIndex (
                                where: { $0.type.rawValue == perturbationOption.type.rawValue} )
                            {
                                showHideAllOptions(show: false)
                                perturbationOptions[tappedItem].isSelected = true

                            }
                        }}
            }
            
            Section(header: Text("driving the tap-driven highway")
                        .foregroundColor(sectionHeaderTextColor)) {
                VStack {
                    bulletedTextItem("tap screen to dismiss dialog")
                    bulletedTextItem("tap 1x to start animating")
                    bulletedTextItem("tap 1x to stop animating")
                    bulletedTextItem("tap 2x to revert to original shape")
                    bulletedTextItem("rinse/repeat")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.defaultMinListRowHeight, 34)
    }
    
    func showHideAllOptions(show: Bool) {
        for ix in 0..<perturbationOptions.count {
            perturbationOptions[ix].isSelected = show ? true : false
        }
    }
    
    func bulletedTextItem(_ text: String) -> some View {
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
