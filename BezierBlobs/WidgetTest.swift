//
//  CurveSettings.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-09.
//

import SwiftUI

extension View {
    func measure() -> some View {
        overlay(GeometryReader { gr in
            Text("{w: \(Int(gr.size.width)), h: \(Int(gr.size.height))}")
                .italic()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
    }
}

extension View {
    func centerPoint() -> some View {
        overlay(GeometryReader { reader in
            ZStack {
                Circle().frame(width: 12, height: 12)
                    .foregroundColor(.white)
                Circle().frame(width: 10, height: 10)
                    .foregroundColor(.red)
                Circle().frame(width: 3, height: 3)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            //            overlay(
            //                Circle()
            //                    .frame(width: 12, height: 12, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            //                    .foregroundColor(.red)
            
        })
    }
}

struct GearLayer: View {
    var color: Color
    var size: CGSize
    var body: some View {
        Text(Image(systemName: "gearshape.fill"))
            .font(.largeTitle).fontWeight(.black)
            .foregroundColor(color)
            .frame(width: size.width, height: size.height)
    }
}

struct GearButton : View {
    
    var edgeColor: Color
    var faceColor: Color
    let s = CGSize(width: 50, height: 50)
    
    var body : some View {
        ZStack {
            GearLayer(color: edgeColor, size: s)
                .offset(x: -3, y : -3)
            GearLayer(color: Color.init(white: 0.25), size: s)
                .scaleEffect(0.9)
            GearLayer(color: Color.init(white: 0.25), size: s)
                .scaleEffect(1.05)
            GearLayer(color: faceColor, size: s)
        }
//        .frame(width: 200, height: 100)
//        .scaleEffect(1.8)
//        .background(Color.green)
    }
}

struct GearButtonTest : View {
    
    var body : some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    GearButton(edgeColor: .orange, faceColor: .blue)
                    GearButton(edgeColor: .yellow, faceColor: .blue)
                    GearButton(edgeColor: .red, faceColor: .blue)
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
            Color.init(white: 0.4)
            VStack {
                GearButton(edgeColor: .black, faceColor: .white)
                GearButton(edgeColor: .orange, faceColor: .blue)
                GearButton(edgeColor: .yellow, faceColor: .blue)
                GearButton(edgeColor: .red, faceColor: .blue)
            }
        }
    }
}
