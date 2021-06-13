//
//  OtherScreenUI.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-09.
//

import SwiftUI

extension View {
    func displayScreenSizeMetrics(frontColor: Color, backColor: Color) -> some View {
        overlay(GeometryReader { gr in
            
            Text("w: \(Int(gr.size.width)) x h: \(Int(gr.size.height))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(backColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: 1, y: 1)
            Text("w: \(Int(gr.size.width)) x h: \(Int(gr.size.height))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(frontColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
    }
}

extension View {
    func bullseye(color: Color = .red) -> some View {
        let r : CGFloat = 14
        return ZStack {
            Circle().frame(width: r, height: r)
                .foregroundColor(.white)
            Circle().frame(width: r - 1, height: r - 1)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//MARK:-
struct PencilSymbolView: View {
    let name : String
    var color: Color
    var size: CGSize
    var body: some View {
        Text(Image(systemName: name))
            .font(.largeTitle).fontWeight(.black)
            .foregroundColor(color)
            .frame(width: size.width, height: size.height)
    }
}

//MARK:-
struct BezelFrame : View {
    let color: Color
    let size: CGSize
    
    var body: some View {
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

//MARK:-
struct TwoButtonPanel : View {
    
    @Binding var showLayersList : Bool
    @Binding var showMiscOptionsList : Bool
    
    @EnvironmentObject var colorScheme : ColorScheme
    
    var baseOffset = CGSize(width: 2.25, height: 2.25)
    var edgeOffset = CGSize(width: 2, height: 2)
    let buttonSize = CGSize(width: 80, height: 60)
    
    var body: some View {
        
//        let locationDependentEdgeColor = MainScreenUI.TWO_BUTTON_PANEL_ON_LEFT ?
//                                            Gray.dark :
//                                            Gray.light
        HStack {
            Spacer()
            
            SELayersChooserButton(buttonSize: buttonSize,
                                  faceColor: colorScheme.buttonFace,
                                  edgeColor: colorScheme.buttonEdge,
                                  baseOffset: baseOffset,
                                  edgeOffset: edgeOffset)
                .onTapGesture {
                    showLayersList.toggle()
                }
            Spacer()
            
            MiscOptionsChooserButton(buttonSize: buttonSize,
                                     iconName: PencilSymbol.PENCIL_AND_ELLIPSIS,
                                     faceColor: colorScheme.buttonFace,
                                     edgeColor: colorScheme.buttonEdge,
                                     baseOffset: baseOffset,
                                     edgeOffset: edgeOffset)
                .onTapGesture {
                    showMiscOptionsList.toggle()
                }
        }
        .scaleEffect(1.1)
    }
}

//  Image(systemName: "checkmark.rectangle.fill")
//  Image(systemName: "checkmark.rectangle.portrait.fill")
//  Image(systemName: "checkmark.square.fill")

struct CheckBox : View {
    var checked: Bool
    var body: some View {
        ZStack {
            SFSymbol.checkbox_unchecked
                .font(.title3).foregroundColor(.gray)
            if checked {
                SFSymbol.checkbox_checked
                    .font(.headline) .foregroundColor(.green)
            }
        }
    }
}

//MARK:-
struct LayerStackSymbol: View {
    var color: Color
    var size: CGSize
    var body: some View {
        // NOTA: can't use SFSymbol...shortcut here
        Text(Image(systemName: "square.stack.3d.up"))
            .font(.largeTitle).fontWeight(.black)
            .foregroundColor(color)
            .frame(width: size.width, height: size.height)
    }
}

struct BulletedTextItem : View {
    var text: String = ""
    
    var body: some View {
        SFSymbol.circle
            .font(.system(size: 8))
            .foregroundColor(.black)
        Spacer(minLength: 5)
        Text(text)
            .frame(width: 360, height: 32, alignment: .leading)
    }
}

//MARK:-
struct MiscOptionsChooserButton : View {
    
    var buttonSize: CGSize
    var iconName: String
    var faceColor: Color
    var edgeColor: Color
    var baseOffset: CGSize
    var edgeOffset: CGSize
    
    var body : some View {
        ZStack {
            // the base
            PencilSymbolView(name: iconName, color: Gray.dark, size: buttonSize)
                .offset(baseOffset)
            
            // the highlight
            PencilSymbolView(name: iconName, color: edgeColor, size: buttonSize)
                .offset(edgeOffset)

            //  and then the face
            PencilSymbolView(name: iconName, color: faceColor, size: buttonSize)
            
        }
    }
}

//MARK:-
struct SELayersChooserButton : View {
    var buttonSize: CGSize
    var faceColor: Color
    var edgeColor: Color
    var baseOffset: CGSize
    var edgeOffset: CGSize
    
    var body : some View {
        ZStack {
            // the base
            LayerStackSymbol(color: Gray.dark, size: buttonSize)
                .offset(baseOffset)
            
            // the highlight
            LayerStackSymbol(color: edgeColor, size: buttonSize)
                .offset(edgeOffset)
            
            // and then the face
            LayerStackSymbol(color: faceColor, size: buttonSize)
        }
    }
}

//MARK:-
struct PencilSymbol {
    static let PENCIL = "pencil"
    static let PENCIL_AND_SQUARE = "square.and.pencil"
    static let PENCIL_AND_ELLIPSIS = "rectangle.and.pencil.and.ellipsis"
    static let PENCIL_AND_OUTLINE = "pencil.and.outline"
}

//MARK:-
struct ScreenButtons_Previews: PreviewProvider {
    static var previews: some View {
        
        var baseOffset = CGSize(width: 2, height: 2)
        let edgeOffset = CGSize(width: 1, height: 1)
        let buttonSize = CGSize(width: 80, height: 60)
        
        ZStack {
            Color.init(white: 0.4)
            VStack {
                MiscOptionsChooserButton(buttonSize: buttonSize,
                                         iconName: PencilSymbol.PENCIL,
                                         faceColor: .blue,
                                         edgeColor: .pink,
                                         baseOffset:  baseOffset,
                                         edgeOffset: edgeOffset)
                    .border(Color.black, width: 0.25)
                MiscOptionsChooserButton(buttonSize: buttonSize,
                                         iconName: PencilSymbol.PENCIL_AND_SQUARE,
                                         faceColor: .blue,
                                         edgeColor: .pink,
                                         baseOffset: baseOffset,
                                         edgeOffset: edgeOffset)
                    .border(Color.black, width: 0.25)
                MiscOptionsChooserButton(buttonSize: buttonSize,
                                         iconName: PencilSymbol.PENCIL_AND_OUTLINE,
                                         faceColor: .blue,
                                         edgeColor: .orange,
                                         baseOffset: baseOffset,
                                         edgeOffset: edgeOffset)
                    .border(Color.white, width: 0.25)
                MiscOptionsChooserButton(buttonSize: buttonSize,
                                         iconName: PencilSymbol.PENCIL_AND_ELLIPSIS,
                                         faceColor: .blue,
                                         edgeColor: .orange,
                                         baseOffset: baseOffset,
                                         edgeOffset: edgeOffset)
                    .border(Color.white, width: 0.25)
            }
        }
        .scaleEffect(3.5)
    }
}
