//
//  CurveSettings.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-12-09.
//

import SwiftUI
struct SettingsGearButton : View {
    
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
        
    struct TestView: View {
        
        var edgeColor: Color
        var faceColor: Color

        var body : some View {
            ZStack {

                GearLayer(color: edgeColor, size: CGSize(width: 80, height: 80))
                    .offset(x: -3, y : -3)
//
                Text(Image(systemName: "gearshape.fill"))
                    .font(.largeTitle).fontWeight(.black)
                    .foregroundColor(Color.init(white: 0.25))
                    .frame(width: 80, height: 80)
                    .scaleEffect(0.9)
                
                Text(Image(systemName: "gearshape.fill"))
                    .font(.largeTitle).fontWeight(.black)
                    .foregroundColor(Color.init(white: 0.25))
                    .frame(width: 80, height: 80)
                    .scaleEffect(1.05)
                
                Text(Image(systemName: "gearshape.fill"))
                    .font(.largeTitle).fontWeight(.black)
                    .foregroundColor(faceColor)
                    .frame(width: 80, height: 80)
            }
            .frame(width: 200, height: 200)
            //.border(Color.red)
            .scaleEffect(2.0)
//            .border(Color.white)
        }
    }
    
    var body : some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    SettingsGearButton.TestView(edgeColor: .orange,
                                                faceColor: .blue)
                }
                .padding(70)
                //.border(Color.green)
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
                SettingsGearButton.TestView(edgeColor: .black, faceColor: .white)
                SettingsGearButton.TestView(edgeColor: .orange, faceColor: .blue)
                SettingsGearButton.TestView(edgeColor: .yellow, faceColor: .blue)
                SettingsGearButton.TestView(edgeColor: .red, faceColor: .blue)
            }
        }
    }
}
