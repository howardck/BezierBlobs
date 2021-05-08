//
//  PageDescTEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-05-06.
//

import SwiftUI

typealias PageDesc_1 = (order: Double, numPoints: Int)
typealias PageDesc_2 = (type: PerturbType, order: Double, numPoints: Int)
typealias PageDesc_3 = (page : Int, order: Double, numPoints: Int)

enum PerturbType {
    case fixedZigZag
    case randomZigZag
    case randomAnywhere
}

struct Pages_3 {
    static let pages : [[PageDesc_2]] =
    [
        //  tab entries for
        [
            (type: .fixedZigZag, order: 1.0, numPoints: 10),
            (type: .randomZigZag, order: 2.0, numPoints: 20)
        ]
    ]
}
struct Pages_1 {
    static let pages : [PageDesc_2] =
    [
        (type : .fixedZigZag, order: 1.0, numPoints: 10),
        (type : .fixedZigZag, order: 2.0, numPoints: 20),
        
        (type : .randomZigZag, order: 3.0, numPoints: 10),
        (type : .randomZigZag, order: 4.0, numPoints: 20)
    ]
}

struct Pages_2 {
    static let pages_2 : [PerturbType : [PageDesc_1] ] =
    [
        .fixedZigZag :
            [
            (order : 1.0, numPoints : 10),
            (order : 2.0, numPoints: 20)
            ],
        .randomZigZag :
            [
            (order : 3.0, numPoints : 30),
            (order : 4.0, numPoints: 40)
            ],
        .randomAnywhere :
            [
            (order : 5.0, numPoints : 50),
            (order : 6.0, numPoints: 60)
            ]
    ]
}


struct PageDescTEST: View {
    var body: some View {
        Text("Hello, World!")
    }
}



struct PageDescTEST_Previews: PreviewProvider {
    static var previews: some View {
        PageDescTEST()
    }
}
