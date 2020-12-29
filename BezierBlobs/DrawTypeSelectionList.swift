//
//  DrawTypeSelectionList.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-29.
//

import SwiftUI

struct DrawTypeSelectionList: View {
    var body: some View {
        Text("Hello, World!")
    }
}

enum DrawType {
    case stroke
    case fill
}

struct DrawTypeItem: Identifiable {
    var id :  Int
    var drawType : DrawType
    var isSelected = false

}

struct DrawTypeList : View {
    @Binding var drawTypeItems : [ DrawTypeItem ]
    var body : some View {
        Text("Hello!")
    }
}

struct DrawTypeSelectionList_Previews: PreviewProvider {
    static var previews: some View {
        DrawTypeSelectionList()
    }
}
