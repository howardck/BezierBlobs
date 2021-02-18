//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

enum PageType : String {
    case circle = "CIRCLE"
    case superEllipse = "CLASSIC"
    case deltaWing = "DELTA WING"
    case killerMoth = "MONSTER"
}

typealias PageDescription = (numPoints: Int,
                             n: Double,
                             offsets: (in: CGFloat, out: CGFloat),
                             perturbLimits: PerturbationLimits,
                             forceEqualAxes: Bool)
struct PageView: View {
        
    let description: PageDescription
    let size: CGSize
    
    static let descriptions : [PageDescription] =
    [
        (numPoints: 14, n: 2.0,
         offsets: (in: -0.25, out: 0.25), perturbLimits: (inner: 0.5, outer: 1.0),
         forceEqualAxes: true),
        
        (numPoints: 20, n: 3.8,
         offsets: (in: -0.2, out: 0.25), perturbLimits: (inner: 0.6, outer: 1.0), false),
        
        (numPoints: 6, n: 3,
         offsets: (in: -0.45, out: 0.35), perturbLimits: (inner: 0.0, outer: 0.0), false),
        
        (numPoints: 24, n: 1,
         offsets: (in: -0.1, out: 0.4), perturbLimits: (inner: 4, outer: 0.4), false)
    ]
            
    @ObservedObject var model = Model()
    @EnvironmentObject var layers : SuperEllipseLayers
    @EnvironmentObject var options : Options
    
    static let timerTimeIncrement : Double = 4.5
    static let animationTimeIncrement : Double = 3.0
    static let timerInitialTimeIncrement : Double = 0.0
    
    @State var smoothed = false

    @State var showLayersList = true
    @State var showMoreOptionsList = false
    
    @State var timer: Timer.TimerPublisher
                            = Timer.publish(every: PageView.timerTimeIncrement,
                                            on: .main, in: .common)
    @State var isAnimating = false
    @State var isFirstTappedCycle = true
        
    var pageType: PageType
    
    //MARK:-
    init(pageType: PageType, description: PageDescription, size: CGSize) {
        
        //print("PageView.init( PageType.\(pageType.rawValue) )")

        self.pageType = pageType
        self.description = description
        self.size = CGSize(width: size.width * PlatformSpecifics.IPAD.w,
                           height: size.height * PlatformSpecifics.IPAD.h)
        
        model.calculateSuppportCurves(for: pageType,
                                          pageDescription: description,
                                          axes: (a: Double(self.size.width/2),
                                                 b: Double(self.size.height/2)))
     }
    
    struct PageGradientBackground : View {
        let colors : [Color] = [.init(white: 0.7), .init(white: 0.3)]
        var body : some View {
            
            LinearGradient(gradient: Gradient(colors: colors),
                           startPoint: .topLeading,
                           endPoint: .bottom)
        }
    }
    
    var body: some View {
    
        ZStack {

            PageGradientBackground()
                        
    //MARK:-
    //MARK: show the following SuperEllipse layer stacks if so flagged

            // comparing testing for visibility here vs inside the
            // called SuperEllipse stack itself via @EnvironmentObject.
            // (think I like testing for it here. maybe ...)
            AnimatingBlob_Filled(curve: model.blobCurve,
                                 layerType: .blob_filled)
            
            if layers.isVisible(layerWithType: .blob_stroked) {
                AnimatingBlob_Stroked(curve: model.blobCurve)
            }
            
            if layers.isVisible(layerWithType: .zigZags_with_markers) {
                ZigZags(curves: model.zigZagCurves)
            }
            if layers.isVisible(layerWithType: .normals) {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   style: markerStyles[.envelopeBounds]!)
            }
 
            if layers.isVisible(layerWithType: .baseCurve) {
                BaseCurve(vertices: model.baseCurve.map{$0.vertex})
            }
            
            if layers.isVisible(layerWithType: .envelopeBounds) {
                EnvelopeBounds(curves: model.boundingCurves,
                               style: markerStyles[.envelopeBounds]!)
            }
            
            if layers.isVisible(layerWithType: .zigZags_with_markers) {
                ZigZag_Markers(curves: model.zigZagCurves,
                               zigStyle : markerStyles[.zig]!,
                               zagStyle : markerStyles[.zag]!)
            }

            Group {
//                if options.isSelected(optionWithType: .smoothed) {
//                    Text("SELECTED")
//                        .font(.custom("courier", size: 42))
//                        .fontWeight(.heavy)
//                        .foregroundColor(.green)
//                }
                
                if layers.isVisible(layerWithType: .baseCurve_markers) {
                    BaseCurve_Markers(curve: model.baseCurve.map{$0.vertex} ,
                                      style: markerStyles[.baseCurve]!)
                }
                if layers.isVisible(layerWithType: .blob_markers) {
                    AnimatingBlob_Markers(curve: model.blobCurve,
                                          style: markerStyles[.blob]!)
                }
                if layers.isVisible(layerWithType: .blob_vertex_0_marker) {
                    AnimatingBlob_VertexZeroMarker(animatingCurve: model.blobCurve,
                                                   markerStyle: markerStyles[.vertexOrigin]!)
                }
            }
        }
        // can't do this because all layers might be turned off,
        // in which case the view disappears on us!
        //  .background(PageGradientBackground())
        
//        .onAppear {
//            print("PageView.onAppear( PageType.\(pageType.rawValue) )" )
//        }
        .onDisappear {
            print("PageView.onDisappear( PageType.\(pageType.rawValue) )")
            
            isAnimating = false
            
            // Animator.stopTimer()
            timer.connect().cancel()
        }
        .onTapGesture(count: 2) {
            
            withAnimation(Animation.easeInOut(duration: 0.6))
            {
                isAnimating = false
                timer.connect().cancel()
                
                model.returnToInitialConfiguration()
            }
        }
        .onReceive(timer) { _ in
            withAnimation(Animation.easeOut(duration: PageView.animationTimeIncrement))
            {
                model.animateToNextZigZagPhase()
            }
            
            if isFirstTappedCycle {
                isFirstTappedCycle.toggle()
                
                timer.connect().cancel()
                timer = Timer.publish(every: PageView.timerTimeIncrement,
                                      on: .main, in: .common)
                _ = timer.connect()
            }
        }
        .onTapGesture(count: 1)
        {
            if showLayersList || showMoreOptionsList {
                showLayersList = false
                showMoreOptionsList = false
            }
            else {
                if !isAnimating {
                    isAnimating = true
            
                    isFirstTappedCycle = true
                    timer = Timer.publish(every: PageView.timerInitialTimeIncrement,
                                          on: .main, in: .common)
                    _ = timer.connect()
                }
                else {
                    isAnimating = false
                    timer.connect().cancel()
                }
            }
        }
        .overlay(displaySuperEllipseMetrics())
        .displayScreenSizeMetrics(frontColor: .black, backColor: .init(white: 0.7))
        
        .overlay(
            VStack {
                Spacer()
                if showLayersList {
                    let s = CGSize(width: 280, height: 600)
                    HStack {
                        ZStack {
                            LayersSelectionList(layers: $layers.layers)
                                .frame(width: s.width, height: s.height)
                            BezelFrame(color: .orange, size: s)
                        }
                        .padding(30)
                        Spacer()
                    }
                }
                else if showMoreOptionsList {
                    let s = CGSize(width: 290, height: 133)
                    HStack {
                        ZStack {
                            MoreOptionsChooserList(options: $options.options)
                                .frame(width: s.width, height: s.height)
                            BezelFrame(color: .orange, size: s)
                        }
                        .padding(30)
                        Spacer()
                    }
                }
                else {
                    let s = CGSize(width: 266, height: 130)
                    HStack {
                        TwoButtonPanel(showLayersList: $showLayersList,
                                       showMoreOptionsList: $showMoreOptionsList)
                            .frame(width: s.width)
                            .padding(EdgeInsets(top: 0, leading: 30, bottom: 50, trailing: 0))
                        Spacer()
                    }
                }
            }
        )
    }
    
    struct TwoButtonPanel : View {
        
        @Binding var showLayersList : Bool
        @Binding var showMoreOptionsList : Bool
        
        var body: some View {
            HStack {
                Spacer()
                
                LayersSelectionListButton(faceColor: .blue, edgeColor: .orange)
                    .onTapGesture {
                        showLayersList.toggle()
                    }
                Spacer()
                
                MoreOptionsListButton(iconName: PencilSymbol.PENCIL_AND_ELLIPSIS,
                                      faceColor: .blue, edgeColor: .orange)
                    .onTapGesture {
                        showMoreOptionsList.toggle()
                    }
                Spacer()
            }
            .scaleEffect(1.1)
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
    
    func displaySuperEllipseMetrics() -> some View {
        VStack(spacing: 10) {
            DropShadowedText(text: "numPoints: \(description.numPoints)",
                             foreColor: .white,
                             backColor: .init(white: 0.2))
            DropShadowedText(text: "n: \(description.n.format(fspec: "3.1"))",
                             foreColor: .white,
                             backColor: .init(white: 0.2))
        }
   }
}

//MARK:-
struct DropShadowedText : View {
    var text: String
    var foreColor: Color
    var backColor: Color
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Text(text)
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(backColor)
                    .offset(x: 2, y: 2)
                Text(text)
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(foreColor)
            }
        }
    }
}

//MARK:-

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pageType: PageType.circle, description: PageView.descriptions[0], size: CGSize(width: 650, height: 550))
    }
}
