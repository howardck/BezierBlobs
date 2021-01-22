//
//  MainScreenLayoutTest.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-01-22.
//

import SwiftUI

struct MainScreenLayoutTest: View {
    
    @State var showList = true
    let size = CGSize(width: 300, height: 625)
    
    var body: some View {
        
        Text("Hello, World! Now is the time to vote. I'm pretending to be a List!")
            .font(.title2)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .foregroundColor(.black)
            .padding(8)
            .background(Color.init(white: 0.7))
            .onTapGesture {
                showList.toggle()
            }
            
            .overlay(
                showListOrTwoButtons(showList: showList, padding: 60)
            )
    }
    
    func showListOrTwoButtons(showList: Bool, padding: CGFloat) -> some View {
        VStack {
            Spacer() // push the choosen object downward
            HStack {
                if showList {
                    ListThingie(size: size).padding(padding)
                }
                else {
                    TwoButtons(size: size).padding(padding)
                }
                Spacer() // push the choosen object to the left
            }
        }
    }
    
}

struct ListThingie : View {
    var size: CGSize
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .frame(width: size.width, height: size.height)
            .foregroundColor(.orange)
            .overlay(
                Text("I'm an overlay!").font(.title2)
                    .padding(6).background(Color.black).foregroundColor(.white))
    }
}

struct TwoButtons : View {
    var size: CGSize
    
    var body: some View {
        Color.blue.frame(width: size.width, height: 80)
    }
}

struct MainScreenLayoutTest_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenLayoutTest()
    }
}
