//
//  CurveSettings.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-09.
//

import SwiftUI

extension View {
    func measure(color: Color = .black) -> some View {
        overlay(GeometryReader { gr in
            Text("w: \(Int(gr.size.width)) x h: \(Int(gr.size.height))")
                .font(.caption)
                .fontWeight(.light)
                .foregroundColor(color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
    }
}

extension View {
    func centerPoint(color: Color = .red) -> some View {
        overlay(GeometryReader { reader in
            ZStack {
                Circle().frame(width: 12, height: 12)
                    .foregroundColor(.white)
                Circle().frame(width: 10, height: 10)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
    }
}

struct GearLayer: View {
    var color: Color
    var size: CGSize
    var body: some View {
//        Text(Image(systemName: "gearshape.fill"))
        Text(Image(systemName: "square.stack.3d.up"))
            .font(.largeTitle).fontWeight(.black)
            .foregroundColor(color)
            .frame(width: size.width, height: size.height)
    }
}

struct SquareStackSymbol : View {
    
    var edgeColor: Color
    var faceColor: Color
    let s = CGSize(width: 50, height: 50)
    
    var body : some View {
        ZStack {
            // first the base (or edge) shadow
            GearLayer(color: edgeColor, size: s)
                .offset(x: 1, y : 1)
            GearLayer(color: faceColor, size: s)
        }
    }
}

struct GearButtonTest : View {
    
    var body : some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    SquareStackSymbol(edgeColor: .orange, faceColor: .blue)
                    SquareStackSymbol(edgeColor: .yellow, faceColor: .blue)
                    SquareStackSymbol(edgeColor: .red, faceColor: .blue)
                }
                .padding(12)
                .background(Color.red)
            }
        }
    }
}

struct WidgetTest: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    Text("I'm a widget")
                        .frame(width: 300, height: 30, alignment: .leading)
                        .padding(0)
                        .background(Color.white)
                        .padding(6)
                    Text("me too!")
                        .frame(width: 300, height: 30, alignment: .leading)
                        .padding(0)
                        .background(Color.white)
                        .padding(6)
                }
                .border(Color.blue, width: 1)
                .background(Color.init(white: 0.85))
                .padding(40)
                .border(Color.red, width: 1)
            }
        }
    }
}

struct CurveSettingsView_Previews: PreviewProvider {
    static var previews: some View {
 
        ZStack {
            Color.gray
            SquareStackSymbol(edgeColor: .red, faceColor: .blue)
                .scaleEffect(3)
                .padding(50)
        }
    }
}
