//
//  EnumPerturbOptions_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-11.
//

import SwiftUI

class EnumBasedListModel : ObservableObject {
    
}



struct EnumPerturbOptions_TEST: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .font(.largeTitle)
            .background(Color.red)
            .foregroundColor(.orange)
            .frame(width: 400, height: 200, alignment: .leading)
            .background(Color.yellow)
            .border(Color.blue)
            .onAppear {
                print("EnumPerturbOptions_TEST().onAppear()")
            }
    }
}

struct EnumPerturbOptions_TEST_Previews: PreviewProvider {
    static var previews: some View {
        EnumPerturbOptions_TEST()
    }
}
