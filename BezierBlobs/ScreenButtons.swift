//
//  CurveSettings.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-09.
//

import SwiftUI

extension View {
    func displayScreenSizeMetrics(color: Color = .black) -> some View {
        overlay(GeometryReader { gr in
            Text("w: \(Int(gr.size.width)) x h: \(Int(gr.size.height))")
                .font(.caption)
                .fontWeight(.regular)
                .foregroundColor(color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
    }
}

extension View {
    func bullseye(color: Color = .red) -> some View {
        let r : CGFloat = 12
        return ZStack {
            Circle().frame(width: r, height: r)
                .foregroundColor(.yellow)
            Circle().frame(width: r - 1, height: r - 1)
                .foregroundColor(color)
            Circle().frame(width: 2.5, height: 2.5)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PencilSymbol: View {
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

struct HighlightedPencilButton : View {
    let name: String
    var faceColor: Color
    var edgeColor: Color
    let s = CGSize(width: 70, height: 50)
    
    var body : some View {
        ZStack {
            // the highlight
            PencilSymbol(name: name, color: edgeColor, size: s)
                .offset(x: 1, y : 1)
            // and then the face
            PencilSymbol(name: name, color: faceColor, size: s)
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

struct HighlightedLayerStackButton : View {
    var faceColor: Color
    var edgeColor: Color
    let s = CGSize(width: 70, height: 50)
    
    var body : some View {
        ZStack {
            // the base (or edge) on the bottom
            LayerStackSymbol(color: edgeColor, size: s)
                .offset(x: 1, y : 1)
            // and then the face
            LayerStackSymbol(color: faceColor, size: s)
        }
    }
}

let pencil = "pencil"
let pencilInSquare = "square.and.pencil"
let pencilWithEllipsis = "rectangle.and.pencil.and.ellipsis"
let pencilInsideSquiggle = "pencil.and.outline"

struct ScreenButtons_Previews: PreviewProvider {
    static var previews: some View {
        
        ZStack {
            Color.init(white: 0.4)
            VStack {
                HighlightedPencilButton(name: pencil,
                                        faceColor: .blue,
                                        edgeColor: .pink)
                    .border(Color.pink, width: 0.5)
                HighlightedPencilButton(name: pencilInSquare,
                                        faceColor: .blue,
                                        edgeColor: .pink)
                    .border(Color.pink, width: 0.5)
                HighlightedPencilButton(name: pencilWithEllipsis,
                                        faceColor: .blue,
                                        edgeColor: .orange)
                    .border(Color.pink, width: 0.5)
                HighlightedPencilButton(name: pencilInsideSquiggle,
                                        faceColor: .blue,
                                        edgeColor: .orange)
                    .border(Color.pink, width: 0.5)
            }
        }
        .scaleEffect(3.5)
    }
}
