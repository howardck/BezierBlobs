//
//  EnumListingTest.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-11.
//

import SwiftUI

enum TestPerturbationType : String, Equatable, CaseIterable {
    case staticZigZags = "static zig-zags"
    case randomizedZigZags = "randomized zig-zags"
    case randomAnywhereInEnvelope = "random anywhere in envelope"
}

class EnumBasedListModel : ObservableObject {

    @Published var perturbType : TestPerturbationType = .randomAnywhereInEnvelope
}

struct ListTesterView : View {
    
    @ObservedObject var model = EnumBasedListModel()
    var body : some View {
        
        Text("UI for Selecting from an enum").font(.title)
            .padding(10)
        ListChooserView(selection: $model.perturbType)
            .frame(width: 400, height: 200)

    }
}

struct ListChooserView : View {
    
    @Binding var selection : TestPerturbationType
    
    var body : some View {
        
        List {
            ForEach(TestPerturbationType.allCases, id: \.self) { perturbationType in
                OptionRow(isSelected: perturbationType == selection,
                          text: perturbationType.rawValue)
                    .onTapGesture {
                        selection = perturbationType
                    }
            }
        }
        .border(Color.black)
        .onAppear {
            print("currSelection: \"\(selection.rawValue)\"")
        }
    }
}
