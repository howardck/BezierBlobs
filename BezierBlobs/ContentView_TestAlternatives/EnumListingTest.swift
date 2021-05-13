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
   
    @Published var perturbType : TestPerturbationType = .staticZigZags
}

struct ListTesterView : View {
    
    @ObservedObject var model = EnumBasedListModel()
    var body : some View {
        
        Spacer()
        Text("UI for Selecting from an enum").font(.title)
            .padding()
        ListChooserView(selection: $model.perturbType)
            .frame(width: 400, height: 200)
        
        // pickerView not working quite right. not sure I
        // like its look anyway ...
//        PickerView(listSelection: $model.perturbType)
//            .frame(width: 400, height: 200)
        
        Spacer()
    }
}

struct ListChooserView : View {
    
    @Binding var selection : TestPerturbationType
    
    var body : some View {
        
        List {
            ForEach(TestPerturbationType.allCases, id: \.self) { perturbationType in
                let color : Color = perturbationType == selection ? .green : .red
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(color)
                    Text(perturbationType.rawValue).font(.title2)
                }
                .onTapGesture {
                    selection = perturbationType
                    
                }
            }
        }
        .border(Color.orange)
        .onAppear {
            print("currSelection: \"\(selection.rawValue)\"")
        }
    }
}

/*
struct PickerView : View {
    
    @Binding var listSelection : TestPerturbationType
    
    var body : some View {
        
        Form {
            Picker(selection: $listSelection, label: Text("TITLE!")) {
                ForEach(TestPerturbationType.allCases, id: \.self) { perturbationType in
                    Text(perturbationType.rawValue)
                        .tag(perturbationType)
                }
            }
        }
    }
}
*/
