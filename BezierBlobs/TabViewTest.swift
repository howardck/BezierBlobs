//
//  TabViewTest.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-01-20.
//

import SwiftUI

struct SomeView: View {
    let name: String
    var body: some View {
        Text(name)
    }
}

struct TabViewTest: View {
    var body: some View {
        TabView {
            Text("Tab #1")
//            SomeView(name: "I am Tab #1")
                .onAppear{print("TAB PAGE #1 appearing")}
                .onDisappear{print("TAB PAGE #1 disappearing")}
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("TAB 1")
                }
            Text("Tab #2")
//            SomeView(name: "I am Tab #2")
                .onAppear{print("TAB PAGE #2 appearing")}
                .onDisappear{print("TAB PAGE #2 disappearing")}
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("TAB 2")
                }
        }
        .font(.title3)
    }
}

struct TabViewTest_Previews: PreviewProvider {
    static var previews: some View {
        TabViewTest()
    }
}
