//
//  MiscOptionsChooser.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-11.
//

import Combine
import SwiftUI

//MARK:-
struct LabeledCheckboxRow : View {
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
    @Binding var selection : PerturbationStrategy
    
    var body: some View {
        let sectionHeaderTextColor = Color.init(white: 0.1)
        
        List {
            
            Section(header: Text("miscellaneous")) {
                LabeledCheckboxRow(isSelected: smoothed, text: "smoothed")
                    .onTapGesture {
                        smoothed.toggle()
                    }
            }
                    
            Section(header: Text("perturbation strategy")
                .foregroundColor(sectionHeaderTextColor)) {

                ForEach(PerturbationStrategy.allCases, id: \.self) { type in
                    LabeledCheckboxRow(isSelected: type == selection,
                                       text: type.rawValue)
                        .onTapGesture {
                            selection = type
                            print("currSelection: \"\(selection.rawValue)\"")
                        }
                }
            }
            
            Section(header: Text("driving the tap-driven highway")
                        .foregroundColor(sectionHeaderTextColor)) {
                VStack {
                    bulletedTextItem("tap screen: dismisses dialog")
                    bulletedTextItem("tap 1x: start animating")
                    bulletedTextItem("tap 1x: stop animating")
                    bulletedTextItem("tap 2x: revert to original shape")
                    bulletedTextItem("rinse/repeat")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.defaultMinListRowHeight, 34)
    }

    func bulletedTextItem(_ text: String) -> some View {
        HStack(alignment: .center){
            SFSymbol.diamondBullet
                .font(.footnote)
                //.scaleEffect..(0.7)
                .foregroundColor(.orange)
            Spacer(minLength: 6)
            Text(text)
                .frame(width: 360, height: 34, alignment: .leading)
        }
    }
}
