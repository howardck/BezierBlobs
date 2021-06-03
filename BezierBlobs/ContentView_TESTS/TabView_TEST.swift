//
//  TabView_TEST.swift
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

//MARK:-
// testing looks for a 5th Tab to show a book, ie read-me instructions
struct BookSymbol {
    static let CLOSED_BOOK = "book.closed.fill"
    static let CLOSED_TEXTBOOK = "text.book.closed.fill"
}

struct TabViewTest: View {
    var body: some View {
        
        TabView {
 
            Text("")
                .tabItem {
                    SFSymbol.QUESTION_MARK_CIRCLE
                    Text("Help")
                }
            Text("")
                .tabItem {
                    SFSymbol.QUESTION_MARK_CIRCLE_FILL
                    Text("Help")
                }
            Text("")
                .tabItem {
                    SFSymbol.QUESTION_MARK_SQUARE
                    Text("Help")
                }
            Text("")
                .tabItem {
                    SFSymbol.QUESTION_MARK_SQUARE_FILL
                    Text("Help")
                }
            Text("")
                .tabItem {
                    SFSymbol.QUESTION_MARK
                }
            Text("")
                .tabItem {
                    SFSymbol.HAND_WAVE
                    Text("READ ME")
                }
            Text("")
                .tabItem {
                    SFSymbol.HAND_WAVE_FILL
                    Text("READ ME")
                }
            Text("")
                .tabItem {
                    SFSymbol.ABC
                    Text("READ ME")
                }
        }
        
//        TabView {
//            Text("Tab #1")
//                .onAppear{print("TAB PAGE #1 appearing")}
//                .onDisappear{print("TAB PAGE #1 disappearing")}
//                .tabItem {
//                    SFSymbol.CLOSED_BOOK
//                    Text("TAB 1")
//                }
//            Text("Tab #2")
//                .onAppear{print("TAB PAGE #2 appearing")}
//                .onDisappear{print("TAB PAGE #2 disappearing")}
//                .tabItem {
//                    SFSymbol.CLOSED_TEXTBOOK
//                    Text("TAB 2")
//                }
//        }
    }
}

struct TabViewTest_Previews: PreviewProvider {
    static var previews: some View {
        TabViewTest()
    }
}
