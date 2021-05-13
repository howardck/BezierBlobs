//
//  EnumBasedListChooser_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-11.
//

import SwiftUI

enum TestPerturbationType : String, Equatable, CaseIterable {
    case staticZigZags = "fixed zig-zags"
    case randomizedZigZags = "randomized alternating zig-zags"
    case randomAnywhereInHalfEnvelope = "random alternating in half-envelope"
    case randomAnywhereInEnvelope = "random anywhere in envelope"
}

class EnumBasedListModel : ObservableObject {

    @Published var currPerturbationType : TestPerturbationType = .randomAnywhereInEnvelope
}

struct EnumBasedListChooser : View {
    
    @ObservedObject var model = EnumBasedListModel()
    var body : some View {
        
        Text("UI for Selecting an Item from an enum").font(.title)
            .padding(10)
        ListChooserView(selection: $model.currPerturbationType)
            .frame(width: 360, height: 200)
    }
}

struct ListChooserView : View {
    
    @Binding var selection : TestPerturbationType
    
    var body : some View {

        List {
            ForEach(TestPerturbationType.allCases, id: \.self) { perturbationType in
                LabeledCheckboxRow(isSelected: perturbationType == selection,
                                   text: perturbationType.rawValue)
                    .onTapGesture {
                        selection = perturbationType
                        print("currSelection: \"\(selection.rawValue)\"")
                    }
            }
        }
        .border(Color.gray, width: 2)
//        .onAppear {
//            print("currSelection: \"\(selection.rawValue)\"")
//        }
    }
}
