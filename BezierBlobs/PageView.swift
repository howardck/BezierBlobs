//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

enum PageType : String {
    case superEllipse = "CLASSIC SE"
    case circle = "CIRCLE"
    case deltaWing = "DELTA WING"
    case mutantMoth = "MUTANT MOTH"
}

typealias PageDescription
                = (numPoints: Int,
                   n: Double,
                   axisRelOffsets: (inner: CGFloat, baseCurve: Double, outer: CGFloat),
                   blobLimits: ZigZagDeltas,
                   forceEqualAxes: Bool)

struct PageView: View {
        
    let pageDesc: PageDescription
    
    static let descriptions : [PageDescription] =
    [
    // CLASSIC SE
        
        // NOTA: THIS ONE IS GOOD FOR (experimental at the moment)
        //         .zigZagBased pages
        // we do FEWER points because the arms are generally deeper
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        
// TEMPORARILY REPLACING THIS FOR A SMALL NUMBER FOR Live Preview
//        (numPoints: 32,
        (numPoints: 32,
         n: 2.8,
         axisRelOffsets: (inner: 0.5, baseCurve: 0.6, outer: 0.8),
         blobLimits: (inner: 1.0, outer: 0.8), false),
        
        // THIS ONE IS GOOD FOR (experimental )
        //          .envelopeBased pages
        // we do MORE points b/cause the arms are generally shallower
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        
//        (numPoints: 66,
//         n: 3.8,
//         axisRelativeOffsets: (inner: 0.4, baseCurve: 0.6, outer: 1.0),
//         blobLimits: (inner: 1.2, outer: 1.0), false),
//
    // CIRCLE
//        (numPoints: 14,
        (numPoints: 20,
         n: 2.0,
         axisRelOffsets: (inner: 0.49, baseCurve: 0.75, outer: 1.01),
         blobLimits: (inner: 0.6, outer: 0.8),
         forceEqualAxes: true),

    // DELTA WING
        (numPoints: 6,
         n: 3,
         axisRelOffsets: (inner: 0.15, baseCurve: 0.6, outer: 0.95),

         blobLimits: (inner: 0.0, outer: 0.0), false),
        
    // MUTANT MOTH
        (numPoints: 24,
         n: 1,
         axisRelOffsets: (inner: 0.5, baseCurve: 0.6, outer: 0.9),

         blobLimits: (inner: 3.0, outer: 0.8), false)
    ]
            
    @ObservedObject var model = Model()
    @EnvironmentObject var layers : SELayersViewModel
    @EnvironmentObject var options : MiscOptionsModel
    
    @EnvironmentObject var colorScheme : ColorScheme
        
    // lots of room to play w/ the relative time
    // increments, as well as the animation curves.
    
    // if the timer increment is larger than the
    // animation increment, we get a pause between cycles
    static let timerTimeIncrement : Double = 2.8
    static let animationTimeIncrement : Double = 2.7
//  static let animationTimeIncrement : Double = 3.2
    
//    static let animationStyle = Animation.easeOut(duration: PageView.animationTimeIncrement)
    static let animationStyle = Animation.easeOut(duration: PageView.animationTimeIncrement)
    
    static let timerInitialTimeIncrement : Double = 0.0
    
    @State var showLayersList = false
    @State var showMiscOptionsList = false
    
    @State var timer: Timer.TimerPublisher
                            = Timer.publish(every: PageView.timerTimeIncrement,
                                            on: .main, in: .common)
    @State var isAnimating = false
    @State var isFirstTappedCycle = true
    
    var randomPermutations = true
        
    var pageType: PageType
    
    //MARK:- PageView.INIT
    init(pageType: PageType, pageDesc: PageDescription, size: CGSize) {
        
        print("PageView.init(): {PageType.\(pageType)} numPoints: {\(pageDesc.numPoints)} {w: \((size.width).format(fspec: "4.2")), h: \((size.height).format(fspec: "4.2"))}")
        
        if Model.DEBUG_PRINT_PAGEVIEW_INIT_BASIC_AXIS_PARAMS {
            print("PageView.init(pageType.\(pageType.rawValue))")
            print ("PageView.init(). screen size   = W: {\(size.width)}, H: {\(size.height)}")
            print ("PageView.init(). semiAxis size = W: {\((size.width/2).format(fspec: "4.2"))} H: {\((size.height/2).format(fspec: "4.2"))}")
        }
        
        self.pageType = pageType
        self.pageDesc = pageDesc
        
        var a = Double(size.width/2)
        var b = Double(size.height/2)
        let minAxis = CGFloat(min(a, b))
        if pageDesc.forceEqualAxes {
            a = Double(minAxis)
            b = Double(minAxis)
        }
        
        print("semiMinor axis a: {\(a)} semiMajor axis b: {\(b)}")
        
        let baseCurveRatio = pageDesc.axisRelOffsets.baseCurve
        let baseCurve = minAxis * CGFloat(baseCurveRatio)
        
        if Model.DEBUG_ADJUST_PERTURBATION_LIMITS {
            
            print("Model.upscale(blobLimits):")
            print("   baseCurve. ratio: {\(baseCurveRatio.format(fspec: "4.2"))}" +
                    "-> absolute: {\(baseCurve.format(fspec: "4.2"))}")
            print("   axisRelativeOffsets: (inner: \(pageDesc.axisRelOffsets.inner.format(fspec: "4.2")), " +
                "outer: \(pageDesc.axisRelOffsets.outer.format(fspec: "4.2")))")
        }
        
        model.offsets = (inner: minAxis * pageDesc.axisRelOffsets.inner - baseCurve,
                         outer: minAxis * pageDesc.axisRelOffsets.outer - baseCurve)
        
        model.blobLimits = model.upscale(pageDesc.blobLimits,
                                         toMatch: model.offsets)
        
        print("model.calculateSuperEllipse()")
        model.calculateSuperEllipse(for: pageType,
                                    pageDescription: pageDesc,
                                    axes: (a: a * baseCurveRatio,
                                           b: b * baseCurveRatio)
        )
        model.calculateSupportCurves()
    }
    
    struct PageGradientBackground : View {
        let colors : [Color] = [.init(white: 0.7), .init(white: 0.3)]
        var body : some View {
            
//            LinearGradient(gradient: Gradient(colors: colors),
//                           startPoint: .topLeading,
//                           endPoint: .bottom)
            
            Color.orange
        }
    }
    
    var body: some View {
    
        ZStack {

            //PageGradientBackground()
                        
    //MARK:- DISPLAY THE FOLLOWING LAYERS IF FLAGGED
            
            // (just for fun this one uses an @Environment-injected
            // layers object internally to acesss .isVisible)
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
            if layers.isVisible(layerWithType: .offsetsEnvelope) {
                EnvelopeBounds(curves: model.boundingCurves,
                               style: markerStyles[.envelopeBounds]!)
            }
            if layers.isVisible(layerWithType: .zigZags_with_markers) {
                ZigZag_Markers(curves: model.zigZagCurves,
                               zigStyle : markerStyles[.zig]!,
                               zagStyle : markerStyles[.zag]!)
            }
            Group {
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
        .background(colorScheme.background)
        /*  a rather interesting bug:
         
            the view PageGradientBackground() will work in a .background(),
            but all the other remaining views in the PageView.body are
            conditioned, and if all are set to false the PageView "crashes"
         
            .background(PageGradientBackground())
         */

        .onDisappear {
            isAnimating = false
            timer.connect().cancel()
        }
    
        //MARK: onReceive()
        .onReceive(timer) { _ in
            
            //TODO: -- USE AN OPTIONAL FOR options HERE
            
            withAnimation(PageView.animationStyle) {
                
                switch options.currPerturbStrategy {
                
                case .staticZigZags :
                    model.animateToNextZigZagPhase(doRandomDeltas: false)
                    
                case .randomizedZigZags :
                    model.animateToNextZigZagPhase(doRandomDeltas: true)
                    
                case .randomAnywhereInHalfEnvelope :
                    model.animateToRandomOffsetsInAlternatingQuadrants()
                    
                case .randomAnywhereInEnvelope :
                    model.animateToRandomOffsetsAnywhereWithinEnvelope()
                
                case .randomRangeFromAlternatingOffsets :
                
                    model.animateToRandomizedPerturbationInRange()
                }
            }
            
//            withAnimation(PageView.animationStyle)
//            {
//                if options.isSelected(perturbationType: .staticZigZags) {
//                    model.animateToNextZigZagPhase(doRandomDeltas: false)
//                }
//                else if options.isSelected(perturbationType: .randomizedZigZags) {
//                    model.animateToNextZigZagPhase(doRandomDeltas: true)
//                }
//                else {
//                    model.animateToRandomOffsetsAnywhereWithinEnvelope()
//                }
////                model.animateToRandomOffsetInAlternateQuadrant()
//            }

            if isFirstTappedCycle {
                
                print("\nFIRST TAPPED CYCLE!\n")
                isFirstTappedCycle = false
                
                timer.connect().cancel()
                timer = Timer.publish(every: PageView.timerTimeIncrement,
                                      on: .main, in: .common)
                _ = timer.connect()
            }
        }
        //MARK: onTapGesture(2)
        .onTapGesture(count: 2) {
            
            withAnimation(Animation.easeInOut(duration: 0.6))
            {
                isAnimating = false
                timer.connect().cancel()
                
                model.returnToInitialConfiguration()
            }
        }
        
        //MARK: onTapGesture(1)
        .onTapGesture(count: 1)
        {
            if showLayersList || showMiscOptionsList {
                showLayersList = false
                showMiscOptionsList = false
            }
            else {
                if !isAnimating {
                    isAnimating = true
                    
                    // we've never tapped before and we're not yet animating.
                    // ie we've done nothing to date; start the animation.
            
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

            MainScreenUI(showLayersList : $showLayersList,
                         showMiscOptionsList: $showMiscOptionsList)
        )
    }
    
    func displaySuperEllipseMetrics() -> some View {
        VStack(spacing: 10) {
            DropShadowedText(text: "numPoints: \(pageDesc.numPoints)",
                             foreColor: .white,
                             backColor: .init(white: 0.2))
            DropShadowedText(text: "n: \(pageDesc.n.format(fspec: "3.1"))",
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
        PageView(pageType: PageType.circle, pageDesc: PageView.descriptions[0], size: CGSize(width: 650, height: 550))
    }
}
