//
//  MainScreenUI.swift
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

struct TwoButtonPanel : View {
    
    @Binding var showLayersList : Bool
    @Binding var showMiscOptionsList : Bool
    
    var edgeOffset = CGSize(width: 1, height: 1)
    
    var body: some View {
        HStack {
            Spacer()
            
            LayersSelectionListButton(faceColor: .blue,
                                      edgeColor: .orange,
                                      edgeOffset: edgeOffset)
                .onTapGesture {
                    showLayersList.toggle()
                }
            Spacer()
            
            MiscOptionsListButton(iconName: PencilSymbol.PENCIL_AND_ELLIPSIS,
                                  faceColor: .blue,
                                  edgeColor: .orange,
                                  edgeOffset: edgeOffset)
                .onTapGesture {
                    showMiscOptionsList.toggle()
                }
            Spacer()
        }
        .scaleEffect(1.2)
    }
}

struct MiscOptionsListButton : View {
    
    var iconName: String
    var faceColor: Color
    var edgeColor: Color
    var edgeOffset: CGSize

    let s = CGSize(width: 70, height: 50)
    
    var body : some View {
        ZStack {
            // the highlight
            PencilSymbolView(name: iconName, color: edgeColor, size: s)
                .offset(edgeOffset)
            // and then the face
            PencilSymbolView(name: iconName, color: faceColor, size: s)
        }
    }
}

struct LayerStackSymbol: View {
    var color: Color
    var size: CGSize
    var body: some View {
        Text(Image(systemName: "square.stack.3d.up"))
            .font(.largeTitle).fontWeight(.black)
            .foregroundColor(color)
            .frame(width: size.width, height: size.height)
    }
}

struct LayersSelectionListButton : View {
    var faceColor: Color
    var edgeColor: Color
    var edgeOffset: CGSize
    
    let s = CGSize(width: 70, height: 50)
    
    var body : some View {
        ZStack {
            // the base (or edge) on the bottom
            LayerStackSymbol(color: edgeColor, size: s)
                .offset(edgeOffset)
            // and then the face
            LayerStackSymbol(color: faceColor, size: s)
        }
    }
}

struct PencilSymbol {
    static let PENCIL = "pencil"
    static let PENCIL_AND_SQUARE = "square.and.pencil"
    static let PENCIL_AND_ELLIPSIS = "rectangle.and.pencil.and.ellipsis"
    static let PENCIL_AND_OUTLINE = "pencil.and.outline"
}

struct ScreenButtons_Previews: PreviewProvider {
    static var previews: some View {
        
        let edgeOffset = CGSize(width: 1, height: 1)
        
        ZStack {
            Color.init(white: 0.4)
            VStack {
                MiscOptionsListButton(iconName: PencilSymbol.PENCIL,
                                          faceColor: .blue,
                                          edgeColor: .pink,
                                          edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
                MiscOptionsListButton(iconName: PencilSymbol.PENCIL_AND_SQUARE,
                                          faceColor: .blue,
                                          edgeColor: .pink,
                                          edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
                MiscOptionsListButton(iconName: PencilSymbol.PENCIL_AND_OUTLINE,
                                          faceColor: .blue,
                                          edgeColor: .orange,
                                          edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
                MiscOptionsListButton(iconName: PencilSymbol.PENCIL_AND_ELLIPSIS,
                                          faceColor: .blue,
                                          edgeColor: .orange,
                                          edgeOffset: edgeOffset)
                    .border(Color.pink, width: 0.5)
            }
        }
        .scaleEffect(3.5)
    }
}
