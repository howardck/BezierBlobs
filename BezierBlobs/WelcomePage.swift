//
//  WelcomePage.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-08-13.
//

import SwiftUI

struct WelcomePage: View {
    var body: some View {
        
        Color.init(white: 0.7)
            .frame(width: 400, height: 380)

            .overlay(
                ZStack {
                    Color.blue
                    
                    VStack {
                        Spacer().frame(height: 24)
                        VStack {
                            
                            ZStack {
                                Text("Howard Katz")
                                    .font(.title).fontWeight(.thin)
                                    .foregroundColor(Color.init(white: 1))
                                    .offset(x: -0.5, y: -0.5)
                                Text("Howard Katz")
                                    .font(.title).fontWeight(.thin)
                                    .foregroundColor(Color.init(white: 0))
                                    .offset(x: 1, y: 0.7)
                                Text("Howard Katz")
                                    .font(.title).fontWeight(.thin)
                                    .foregroundColor(.yellow)
                            }
                            
                            Spacer().frame(height: 12)
                            
                            VStack(spacing: 3) {
                                ZStack {
                                    Text("@3char")
                                        .font(.headline).fontWeight(.light).italic()
                                        .offset(x: 0.5, y: 0.5)
                                        .foregroundColor(.black)
                                    Text("@3char")
                                        .font(.headline).fontWeight(.light).italic()
                                        .foregroundColor(.white)
                                }
                                
                                ZStack {
                                    Text(verbatim: "howardk@fatdog.com")
                                        .font(.headline).fontWeight(.light).italic()
                                        .offset(x: 0.5, y: 0.5)
                                        .foregroundColor(.black)
                                    Text(verbatim: "howardk@fatdog.com")
                                        .font(.headline).fontWeight(.light).italic()
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer().frame(height: 12)
                            
                            ZStack {
                                Text("welcome. enjoy")
                                    .font(.title2).fontWeight(.light)
                                    .foregroundColor(.black)
                                    .offset(x: 0.5, y: 0.5)
                                Text("welcome. enjoy").font(.title2).fontWeight(.light)
                                    .foregroundColor(.yellow)
                            }
                            
                            Spacer().frame(height: 16)
                        }
                        
                        VStack(alignment: .leading,
                               spacing: 4)
                        {
                            ZStack {
                                Text("ε = 2/n")
                                    .fontWeight(.light)
                                    .offset(x: 0.5, y: 0.5)
                                    .foregroundColor(.black)
                                Text("ε = 2/n")
                                    .fontWeight(.light)
                                    .foregroundColor(.white)
                            }
                            ZStack {
                                Text("x = a * pow(abs(cosT), ε) * sign(cosT)")
                                    .fontWeight(.light)
                                    .offset(x: 0.5, y: 0.5)
                                    .foregroundColor(.black)
                                Text("x = a * pow(abs(cosT), ε) * sign(cosT)")
                                    .fontWeight(.light)
                                    .foregroundColor(.white)
                            }
                            ZStack {
                                Text("y = b * pow(abs(sinT), ε) * sign(sinT)")
                                    .fontWeight(.light)
                                    .offset(x: 0.5, y: 0.5)
                                    .foregroundColor(.black)
                                Text("y = b * pow(abs(sinT), ε) * sign(sinT)").fontWeight(.light)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer().frame(height: 12)
                            
                            ZStack(alignment: .top) {
                                Text("dX = b * ε * pow(abs(sinT), (ε - 1)) * cosT")
                                    .fontWeight(.light)
                                    .offset(x: 0.5, y: 0.5)
                                    .foregroundColor(.black)
                                Text("dX = b * ε * pow(abs(sinT), (ε - 1)) * cosT").fontWeight(.light)
                                    .foregroundColor(.white)
                            }
                            
                            ZStack(alignment: .top) {
                                Text("dY = a * ε * pow(abs(cosT), (ε - 1)) * sinT")
                                    .fontWeight(.light)
                                    .offset(x: 0.5, y: 0.5)
                                    .foregroundColor(.black)
                                Text("dY = a * ε * pow(abs(cosT), (ε - 1)) * sinT")
                                    .fontWeight(.light)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer().frame(height: 20)
                        
//                        ZStack {
//                            Text("「猿も木から落ちる」as they say")
//                                .font(.callout).italic()
//                                .offset(x: 0.5, y: 0.5)
//                                .foregroundColor(.black)
//                            Text("「猿も木から落ちる」as they say")
//                                .font(.callout) .italic()
//                                .foregroundColor(.yellow)
//                        }
                        
                        Spacer().frame(height: 24)
                    }
                }
                    .border(Color.black, width: 1)

            )
    }
}

struct WelcomePage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage()
    }
}
