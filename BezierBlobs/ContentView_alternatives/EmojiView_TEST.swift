//
//  EmojiView_TEST.swift
//  BezierBlobs
//
//  see
//  https://stackoverflow.com/questions/38809425/convert-apple-emoji-string-to-uiimage

//  Created by Howard Katz on 2021-02-14.
//

import SwiftUI
import UIKit

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 100, height: 140)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 100)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

struct EmojiViewTest: View {
    let image = "❤️".image()!
    @State var degrees : Double = 0
    
    var body: some View {
        
        ZStack {
                    
            VStack {
                
                ZStack {
                    Text("Peg o'my heart")
                        .font(.custom("papyrus", size: 42)).fontWeight(.heavy).foregroundColor(.red)
                        .offset(x: -1, y: -1)
                    Text("Peg o'my heart")
                        .font(.custom("papyrus", size: 42)).fontWeight(.heavy).foregroundColor(.blue)
                }
                .padding(20)
                            
                HStack {
                    Image(uiImage: "👁".image()!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 200)
                        .rotationEffect(.degrees(degrees))
                        .animation(.easeInOut(duration: 0.5))
                        .onTapGesture(count: 1) {
                            self.degrees += 360
                        }
                    
//                    RotatingImageView(image: "👁".image()! )
//                        .animation(.easeInOut(duration: 0.5))
//                        .onTapGesture(count: 1) {
//                            self.degrees += 360
//                        }
                    
//                    RotatingImageView(image: "❤️".image()! )
//                        .animation(.easeInOut(duration: 0.5))
//                        .onTapGesture(count: 1) {
//                            self.degrees += 360
//                        }
                    
                    Image(uiImage: "❤️".image()!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 200)
                        .animation(.easeInOut(duration: 0.5))
                        .onTapGesture(count: 1) {
                            self.degrees += 360
                        }
                    
//                    RotatingImageView(image: "U".image()! )
//                        .animation(.easeInOut(duration: 0.5))
//                        .onTapGesture(count: 1) {
//                            self.degrees += 360
//                        }
                    
                    Image(uiImage: "U".image()!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 200)
                        .animation(.easeInOut(duration: 0.5))
                        .onTapGesture(count: 1) {
                            self.degrees += 360
                        }

                }
                .onAppear {
                    self.degrees += 360
                }
            }
            .background( PageGradientBackground_2() )
        }
    }
}

struct RotatingImageView : View {
    
    var image : UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 200)
    }
}

struct PageGradientBackground_2 : View {
    //let colors : [Color] = [.init(white: 0.7), .init(white: 0.3)]
    //let colors : [Color] = [.blue, .yellow]
    let colors : [Color] = [.yellow, .orange, .yellow ]

    var body : some View {
        
        LinearGradient(gradient: Gradient(colors: colors),
                       startPoint: .topLeading,
                       endPoint: .bottom)
    }
}

struct EmojiViewTest_Previews: PreviewProvider {
    static var previews: some View {
        EmojiViewTest()
    }
}
