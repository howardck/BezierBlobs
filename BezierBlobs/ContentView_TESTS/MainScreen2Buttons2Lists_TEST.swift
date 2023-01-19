//
//  MainScreen2Buttons2Lists_TEST.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-12.
//

/*  on quick review it looks like i might have left
    this file in a somewhat inconsistent state.
    if you find any weirdnesses (dead code or an
    inconsistent UI), that's likely why. HK
 */

import SwiftUI

struct MainScreenTwoButtonsTwoLists: View {
    var body: some View {
        PageView_2()
    }
}

struct PageView_2 : View {
    
    @State var showLayerSelectionList = false
    @State var showOtherOptionsSelectionList = false
    
    var body : some View {
        
         Text("I am HE!")
            
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        let s = CGSize(width: 270, height: 625)
                        
                        let range123 = 1..<4
                        let range456 = 4..<7
                        
                        if showLayerSelectionList {
                            ZStack {
                                List {
                                    Section(header: Text(" 123")) {
                                        ForEach( range123 ) { i in Text("\(i)") }
                                    }
                                    Section(header: Text(" 456")) {
                                        ForEach( range456 ) { j in Text("\(j)") }
                                    }
                                }
                                .frame(width: s.width, height: s.height)
                                
                                bezelFrame(color: .orange, size: s)
                            }
                            .padding(75)
                        }
                        else {
                            DrawingAndLayeringButtons(
                                showDrawingOptionsList: $showOtherOptionsSelectionList,
                                showLayerSelectionList: $showLayerSelectionList
                            )
                            .padding(75)
                        }
                        
                        Spacer() // pushes to the left
                    }
                }
            )
    }
    
    private func bezelFrame(color: Color, size: CGSize) -> some View {
           ZStack {
               RoundedRectangle(cornerRadius: 6)
                   .stroke(color, lineWidth: 8)
                   .frame(width: size.width, height: size.height)
               RoundedRectangle(cornerRadius: 6)
                   .stroke(Color.white, lineWidth: 1.25)
                   .frame(width: size.width, height: size.height)
           }
       }
}

struct DrawingAndLayeringButtons : View {
    @Binding var showDrawingOptionsList : Bool
    @Binding var showLayerSelectionList : Bool
    
    let baseOffset = CGSize(width: 2, height: 2)
    var edgeOffset = CGSize(width: 1, height: 1)
    let buttonSize = CGSize(width: 80, height: 60)
        
        var body: some View {
            HStack {
                MiscOptionsChooserButton(buttonSize: buttonSize,
                                         iconName: PencilSymbol.PENCIL,
                                         faceColor: .blue,
                                         edgeColor: .orange,
                                         baseOffset: baseOffset,
                                         edgeOffset: edgeOffset)
                    .onTapGesture {
                        print("DrawingOptions Button tapped")
                        showDrawingOptionsList.toggle()
                    }
                
                Spacer()
                    .frame(width: 60, height: 1)
                
                LayerSelectionListButton_2(faceColor: .blue,
                                         edgeColor: .orange)
                    .onTapGesture {
                        print("LayerSelectionList Button tapped")
                        showLayerSelectionList.toggle()
                    }
            }
            .scaleEffect(1.4)
        }
}

struct LayerStackSymbol_2: View {
    var color: Color
    var size: CGSize
    var body: some View {
        Text(Image(systemName: "square.stack.3d.up"))
            .font(.largeTitle).fontWeight(.black)
            .foregroundColor(color)
            .frame(width: size.width, height: size.height)
    }
}

struct LayerSelectionListButton_2 : View {
    var faceColor: Color
    var edgeColor: Color
    let s = CGSize(width: 70, height: 50)
    
    var body : some View {
        ZStack {
            // the base (or edge) on the bottom
            LayerStackSymbol_2(color: edgeColor, size: s)
                .offset(x: 1, y : 1)
            // and then the face
            LayerStackSymbol_2(color: faceColor, size: s)
        }
    }
}

//struct MainScreenTwoButtonsTwoLists_Previews: PreviewProvider {
//    static var previews: some View {
//        MainScreenTwoButtonsTwoLists()
//    }
//}

struct MainScreenTwoButtonsTwoLists_Previews: PreviewProvider {
    static var previews: some View {

        let baseOffset = CGSize(width: 2, height: 2)
        let edgeOffset = CGSize(width: 1, height: 1)
        let buttonSize = CGSize(width: 80, height: 60)
        
        ZStack {
            Color.init(white: 0.4)
            VStack {
                MiscOptionsChooserButton(buttonSize: buttonSize,
                                         iconName: PencilSymbol.PENCIL,
                                         faceColor: .blue,
                                         edgeColor: .pink,
                                         baseOffset: baseOffset,
                                         edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
                MiscOptionsChooserButton(buttonSize: buttonSize,
                                         
                                         iconName: PencilSymbol.PENCIL_AND_SQUARE,
                                         faceColor: .blue,
                                         edgeColor: .pink,
                                         baseOffset: baseOffset,
                                         edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
                MiscOptionsChooserButton(buttonSize: buttonSize,
                                         iconName: PencilSymbol.PENCIL_AND_OUTLINE,
                                         faceColor: .blue,
                                         edgeColor: .orange,
                                         baseOffset: baseOffset,
                                         edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
                MiscOptionsChooserButton(buttonSize: buttonSize,
                                         iconName: PencilSymbol.PENCIL_AND_ELLIPSIS,
                                         faceColor: .blue,
                                         edgeColor: .orange,
                                         baseOffset: baseOffset,
                                         edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
            }
        }
        .scaleEffect(3.5)
    }
}
