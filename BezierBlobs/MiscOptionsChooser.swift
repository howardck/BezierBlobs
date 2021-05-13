//
//  MiscOptionsChooser.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-11.
//

import Combine
import SwiftUI


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

struct MiscOptionsChooser: View {
    
    @Binding var smoothed : Bool
    @Binding var perturbationOptions : [PerturbationTypeOption]
    
    var body: some View {
        let sectionHeaderTextColor = Color.init(white: 0.1)
        
        List {
            
            Section(header: Text("miscellaneous")) {
                LabeledCheckboxRow(isSelected: smoothed, text: "smoothed")
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
                                
                                // @@@@@@@@@@@@@@@@@@@@@@
                                print("--- Selected PerturbationType: {\(perturbationOptions[tappedItem].type)}")
                                // @@@@@@@@@@@@@@@@@@@@@@
                                
                                // if we have an options.currPerturationType enum
                                // used to switched on in PageView.onReceive(),
                                // this is likely where we'd set it, no?
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

struct MiscOptionsChooser_Previews: PreviewProvider {
    static var previews: some View {

        let edgeOffset = CGSize(width: 1, height: 1)
        
        ZStack {
            Color.init(white: 0.4)
            VStack {
                MiscOptionsChooserButton(iconName: PencilSymbol.PENCIL,
                                         faceColor: .blue,
                                         edgeColor: .pink,
                                         edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
                MiscOptionsChooserButton(iconName: PencilSymbol.PENCIL_AND_SQUARE,
                                         faceColor: .blue,
                                         edgeColor: .pink,
                                         edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
                MiscOptionsChooserButton(iconName: PencilSymbol.PENCIL_AND_OUTLINE,
                                         faceColor: .blue,
                                         edgeColor: .orange,
                                         edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
                MiscOptionsChooserButton(iconName: PencilSymbol.PENCIL_AND_ELLIPSIS,
                                         faceColor: .blue,
                                         edgeColor: .orange,
                                         edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
            }
        }
        .scaleEffect(3.5)
        
    }
}
