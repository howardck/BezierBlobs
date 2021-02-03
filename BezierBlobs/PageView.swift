//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI


enum PageType : String {
    case circle = "CIRCLE"
    case superEllipse = "SUPERELLIPSE"
    case deltaWing = "DELTA WING"
    case killerMoth = "RORSCHACH"
}

typealias PageDescription = (numPoints: Int,
                             n: Double,
                             offsets: (in: CGFloat, out: CGFloat),
                             perturbLimits: PerturbationLimits,
                             forceEqualAxes: Bool)
struct PageView: View {
        
     static let descriptions : [PageDescription] =
        [
            (numPoints: 12, n: 2.0,
             offsets: (in: -0.2, out: 0.35), perturbLimits: (inner: 0.7, outer: 1.2), forceEqualAxes: true),

            (numPoints: 20, n: 3.8,
             offsets: (in: -0.2, out: 0.25), perturbLimits: (inner: 0.6, outer: 1.0), false),

            (numPoints: 6, n: 3,
             offsets: (in: -0.45, out: 0.35), perturbLimits: (inner: 0.0, outer: 0.0), false),

            (numPoints: 24, n: 1,
             offsets: (in: -0.05, out: 0.4), perturbLimits: (inner: 2.4, outer: 0.2), false)
        ]
        
    @ObservedObject var model = Model()
    @ObservedObject var visibilityModel = LayerVisibilityModel()
    
    static var animationTimeIncrement : Double = 2.7
    static var timerTimeIncrement : Double = 3.0
    
    @State var timer: Timer.TimerPublisher = Timer.publish(every: PageView.timerTimeIncrement, on: .main, in: .common)

    @State var showLayerSelectionList = false
    
    let description: PageDescription
    let size: CGSize
    
    @State var isAnimating = false
    @State var isFirstTappedCycle = true
        
    var pageType: PageType
    
    //MARK:-
    init(pageType: PageType, description: PageDescription, size: CGSize) {

        self.pageType = pageType
        self.description = description
        self.size = CGSize(width: size.width * PlatformSpecifics.IPAD.w,
                           height: size.height * PlatformSpecifics.IPAD.h)
        
        model.calculateSuperEllipseCurves(for: pageType,
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
            
        // NOTA: we can't put this inside a .background() modifier b/c if the user turns off
        // visibility on ALL layers, we won't have any subviews left and this view disappears!
            
            PageGradientBackground()
                        
    //MARK:-
    //MARK: show the following SuperEllipse layer stacks if flagged

            if visibilityModel.isVisible(layerWithType: .blob_filled) {
                AnimatingBlob_Filled(curve: model.blobCurve)
            }

            if visibilityModel.isVisible(layerWithType: .blob_stroked) {
                AnimatingBlob_Stroked(curve: model.blobCurve)
            }
            
            if visibilityModel.isVisible(layerWithType: .zigZags_with_markers) {
                ZigZags(curves: model.zigZagCurves)
            }
            
            if visibilityModel.isVisible(layerWithType: .normals) {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   style: markerStyles[.envelopeBounds]!)
            }
            if visibilityModel.isVisible(layerWithType: .baseCurve) {
                BaseCurve(vertices: model.baseCurve.vertices)
            }
            
            if visibilityModel.isVisible(layerWithType: .envelopeBounds) {
                EnvelopeBounds(curves: model.boundingCurves,
                               style: markerStyles[.envelopeBounds]!)
            }

            if visibilityModel.isVisible(layerWithType: .zigZags_with_markers) {
                ZigZag_Markers(curves: model.zigZagCurves,
                               zigStyle : markerStyles[.zig]!,
                               zagStyle : markerStyles[.zag]!)
            }

            Group {
                if visibilityModel.isVisible(layerWithType: .baseCurve_markers) {
                    BaseCurve_Markers(curve: model.baseCurve.vertices,
                                      style: markerStyles[.baseCurve]!)
                }

                if visibilityModel.isVisible(layerWithType: .blob_markers) {
                    AnimatingBlob_Markers(curve: model.blobCurve,
                                          style: markerStyles[.blob]!)
                }

                if visibilityModel.isVisible(layerWithType: .blob_vertex_0_marker) {
                    AnimatingBlob_VertexZeroMarker(animatingCurve: model.blobCurve,
                                                   markerStyle: markerStyles[.vertexOrigin]!)
                }
            }
        }
        // see note at top of ZStack why we can't do this
      //  .background(PageGradientBackground())
        
        .onAppear {
            print("PageView.onAppear( PageType.\(pageType.rawValue) )" )
        }
        .onDisappear {
            print("PageView.onDisappear( PageType.\(pageType.rawValue) )")
            
            isAnimating = false
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

            print("Timer: {\(pageType.rawValue)} animateToNextZigZagPhase()")
            
            if isFirstTappedCycle {
                isFirstTappedCycle = false
                
                // this was a VERY fast cycling timer, so the user wouldn't have to wait.
                // now slow it down to its normal cycle
                
                timer.connect().cancel()
                timer = Timer.publish(every: PageView.timerTimeIncrement, on: .main, in: .common)
                timer.connect()
            }
            
            withAnimation(Animation.easeOut(duration: PageView.animationTimeIncrement))
            {
                model.animateToNextZigZagPhase()
            }
        }
        
        .onTapGesture(count: 1)
        {
            // the layer selection list is up; click anywhere else == close it
            if showLayerSelectionList {
                showLayerSelectionList = false
            }
            else {
                if !isAnimating {
                    isAnimating = true
                    
                    // the first tap cycle needs a short duration, since we don't see anything
                    // happening until 'every:' happens for the first time. set the time interval
                    // to it normal slower self on our first receive().
                    
                    // NOTE there are some animation-startup stutter effects happening
                    // that need to be looked at.
                    
                    isFirstTappedCycle = true
                    timer = Timer.publish(every: 0.4, on: .main, in: .common)
                    timer.connect()
                }
                else { // isAnimating == true; turn it off
                    
                    isAnimating = false
                    timer.connect().cancel()
                }
            }
        }
            
        // a nice thought, but makes center of shape quite busy
        // .overlay(bullseye(color: .green))
        
        .overlay(displaySuperEllipseMetrics())
        .displayScreenSizeMetrics(frontColor: .black, backColor: Color.init(white: 0.6))
        
        // push LayerSelectionList & TwoButtonPanel into the
        // lower-left corner. only one of them is visible at a time.
        
        .overlay(
            
            VStack {
                let s = CGSize(width: 270, height: 625)

                Spacer()
                
                HStack {
                    if showLayerSelectionList {
                        ZStack {
                            LayerVisibilitySelectionList(layers: $visibilityModel.layers)
                                .frame(width: s.width, height: s.height)
                                .overlay(
                                    BezelFrame(color: .orange, size: s)
                                )
                        }
                        .padding(50)
                    }
                    else {
                        
                        LayerSelectionListButton(faceColor: .blue,
                                                 edgeColor: .orange)
                            .onTapGesture {
                                
                                showLayerSelectionList.toggle()
                            }
                            .scaleEffect(1.4)
                            .padding(EdgeInsets(top: 0, leading: 80, bottom: 80, trailing: 0))
                    }
                    
                    Spacer() // pushes to the left
                }
            }
        )
    }
    
    struct DrawingAndLayeringButtons : View {
        @Binding var showDrawingOptionsList : Bool
        @Binding var showLayerSelectionList : Bool
        
        var body: some View {
            HStack {
                DrawingOptionsButton(name: pencilInSquare,
                                          faceColor: .blue,
                                          edgeColor: .orange)
                    .onTapGesture {
                        print("DrawingOptions Button tapped")
                        showDrawingOptionsList.toggle()
                    }
                
                Spacer()
                    .frame(width: 60, height: 1)
                
                LayerSelectionListButton(faceColor: .blue,
                                         edgeColor: .orange)
                    .onTapGesture {
                        print("LayerSelectionList Button tapped")
                        showLayerSelectionList.toggle()
                    }
            }
            .scaleEffect(1.4)
        }
    }
    
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
