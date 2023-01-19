//
//  MiscOptionsChooser.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-11.

import Combine
import SwiftUI

//MARK:-
struct LabeledCheckboxRow : View {
    var isSelected: Bool
    var text : String
    
    var body: some View
    {
        HStack {
            Text(text)
            Spacer()
            CheckBox(checked: isSelected)
        }
    }
// an earlier attempt to put the checkbox first
//        HStack {
//            CheckBox(checked: isSelected)
//            Spacer()
//            Text(text)
////                .frame(width: 200, height: 0, alignment: .leading)
//            // text is aligned along the trailing edge
//                .frame( alignment: .leading)
//        }
    
}

struct MiscOptionsChooser: View {
    
    @Binding var smoothed : Bool
    @Binding var selection : PerturbationStrategy
    
    var body: some View {
        
        List {
            
            Section(header: Text("miscellaneous")) {
                LabeledCheckboxRow(isSelected: smoothed, text: "smoothed")
                    .onTapGesture {
                        smoothed.toggle()
                    }
            }
            Section(header: Text("perturbation strategy")) {

                ForEach(PerturbationStrategy.allCases, id: \.self) { type in
                    LabeledCheckboxRow(isSelected: type == selection,
                                       text: type.rawValue)
                        .onTapGesture {
                            selection = type
                            print("currSelection: \"\(selection.rawValue)\"")
                        }
                }
            }
            Section(header: Text("HOW-TO")) {
                
                howTo()
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.defaultMinListRowHeight, 36)
    }
    
    func howTo() -> some View {

        VStack(alignment: .leading, spacing: 0) {
            Text("Driving the tap-driven highway:")
                .underline()
                .font(.system(size: 19))
                .fontWeight(.light)
                .frame(height: 38)
            HStack {
                Spacer()
                    .frame(width: 5)
                VStack(alignment: .leading) {
                    bulletedTextItem("Tap screen to dismiss chooser")
                    Spacer().frame(width: 1)
                    bulletedTextItem("Tap 1x to start animating")
                    Spacer().frame(width: 1)
                    bulletedTextItem("Tap 1x to stop animating")
                    Spacer().frame(width: 1)
                    bulletedTextItem("Tap 2x to revert to basecurve")
                    Spacer().frame(width: 1)
                    bulletedTextItem("Repeat as desired")
                    Spacer().frame(width: 8)
                }
            }
        }
    }

    func bulletedTextItem(_ text: String) -> some View {
        HStack {
            SFSymbols(rawValue:"circle.fill")
                .font(.system(size: 9))
                .foregroundColor(.blue)
//            Circle()
//                .fill(Color.clear)
//                .frame(width: 1, height: 1)
            //Spacer(minLength: 4)
            Text(text)
                .font(.system(size: 18))
                .fontWeight(.light)
                .frame(//width: 360, height: 32,
                       alignment: .trailing)
        }
    }
}
