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
            
            Section(header: Text("HOW-TO")
                        .foregroundColor(sectionHeaderTextColor)) {
        
                howTo()
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.defaultMinListRowHeight, 36)
    }
    
    func howTo() -> some View {

        VStack(alignment: .leading, spacing: 0) {
            Text("Driving the tap-driven highway")
                .underline()
                .font(.system(size: 18))
                .fontWeight(.light)
                .frame(height: 38)
                
            HStack {
                Spacer()
                    .frame(width: 5)
                VStack(alignment: .center) {
                    bulletedTextItem("Tap screen to dismiss this list")
                    bulletedTextItem("Tap 1x to start animating")
                    bulletedTextItem("Tap again to stop animating")
                    bulletedTextItem("Tap 2x to revert to base shape")
                    bulletedTextItem("Repeat as desired")
                }
            }
        }
    }

    func bulletedTextItem(_ text: String) -> some View {
        HStack(alignment: .center) {
            SFSymbol.oval_filled
                .font(.system(size: 7))
                .foregroundColor(.blue)
            Spacer(minLength: 4)
            Text(text)
                .font(.system(size: 18))
                .fontWeight(.light)
                .frame(width: 360, height: 32, alignment: .leading)
        }
    }
}
