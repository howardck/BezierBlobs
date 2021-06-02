//
//  EnumBasedListChooser_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-11.
//

import SwiftUI

class EnumBasedListModel : ObservableObject  {
    @Published var currPerturbationType : PerturbationStrategy = .randomizedZigZags
}

struct EnumBasedListChooser : View {
    
    @ObservedObject var model = EnumBasedListModel()
    var body : some View {
        
        Text("UI for selecting a choice from an enum").font(.title)
            .padding(10)
        ListChooserView(selection: $model.currPerturbationType)
            .frame(width: 350, height: 190)
    }
}

struct ListChooserView : View {
    
    @Binding var selection : PerturbationStrategy
    
    var body : some View {

        List {
            ForEach(PerturbationStrategy.allCases, id: \.self) { perturbationType in
                LabeledCheckboxRow(isSelected: perturbationType == selection,
                                   text: perturbationType.rawValue)
                    .onTapGesture {
                        selection = perturbationType
                        print("currSelection: \"\(selection.rawValue)\"")
                    }
            }
        }
        .padding(4)
        .border(Color.black, width: 0.4)
    }
}
