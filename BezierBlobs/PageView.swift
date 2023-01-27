//  PageView.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI


// MARK:-
struct PageView: View {

    static let animationNormalStyle
        = Animation.easeOut(duration: AnimationTimer.animationTimeIncrement)
    static let animationQuickMarchStyle
        = Animation.easeOut(duration: AnimationTimer.animationQuickMarchTimeIncrement)
    
    let descriptors: PageDescriptors
    let deviceSizeClass : PlatformSpecifics.SizeClass
    var numPoints : Int = 0
    
    //MARK:- @ObservedObject
    
    @ObservedObject var model = Model()
    @ObservedObject var animationTimer = AnimationTimer()
    
    //MARK:- @EnvironmentObject

    @EnvironmentObject var layers : SELayersModel
    @EnvironmentObject var options : MiscOptionsModel
     
    //MARK:- @State
    
    @State var showLayersList = false
    @State var showMiscOptionsList = false
    
    //MARK:-
    func axesFor(size: CGSize, isCircle: Bool) -> (a: Double, b: Double)
    {
        var a = Double(size.width/2)
        var b = Double(size.height/2)
        if isCircle {
            a = min(a, b); b = a
        }
        return (a, b)
    }
    
    //MARK:- PageView.INIT
    init(descriptors: PageDescriptors,
         size: CGSize,
         deviceSizeClass: PlatformSpecifics.SizeClass) {
        
        self.descriptors = descriptors
        self.deviceSizeClass = deviceSizeClass
        
        let (a, b) = axesFor(size: size, isCircle: descriptors.pageType == .circle)
        
        if DEBUG.PRINT_BASIC_PAGE_INFO {
            DEBUG.printBasicPageInfo(pageType: descriptors.pageType,
                                     numPoints: descriptors.numPoints,
                                     size: size,
                                     axes: (a, b))
        }

        // the following code could likely be simplified. take a look at the
        // init() code in BezierBlobs/SimpleStaticSample/SimpleStaticPageView
        // for initializing a single offset curve in the superellipse example
        // for a how-to starting point ...
        
        let baseCurveScreenRelativeRatio = descriptors.axisRelOffsets.baseCurve
        
        let minAxis = CGFloat(min(a, b))
        let baseCurve = minAxis * CGFloat(baseCurveScreenRelativeRatio)
        
        model.pageType = descriptors.pageType

        // convert from screen-relative ratios to absolute distances from the basecurve
        model.offsets = (inner: minAxis * descriptors.axisRelOffsets.inner - baseCurve,
                         outer: minAxis * descriptors.axisRelOffsets.outer - baseCurve)

        // do the same for relative perturbationDeltas -> absolute pDeltas
        model.calculatePerturbationDeltas(descriptors: descriptors, minAxis: minAxis)
        
        if DEBUG.PRINT_OFFSET_AND_PERTURBATION_RANGES {
            DEBUG.printOffsetAndPerturbationData(descriptors: descriptors,
                                                 offsets: model.offsets,
                                                 ranges: model.perturbationDeltas)
        }

        // an experiment that didn't get very far
        numPoints = numPointsIfCompactSizeDevice(descriptors: descriptors,
                                                 deviceType: deviceSizeClass)
        
        model.calculateSuperEllipse(order: descriptors.n,
                                    numPoints: numPoints,
                                    axes: (a * baseCurveScreenRelativeRatio,
                                           b * baseCurveScreenRelativeRatio) )
        model.calculateOffsetsAndNormalsSupportCurves()
        
        if DEBUG.PRINT_OFFSET_COORDINATES {
            print("[[ OFFSET COORDINATES (inner curve)]]:")
            for (i, offsetPoint) in model.offsetCurves.inner.enumerated() {
                DEBUG.printOffsetCoordinates(i: i, offsetPoint: offsetPoint)
            }
        }
    }

    //MARK: -

    /*   a somewhat dissatisfying experiment; sort of defeats the purpose
         of having a descriptors setup in the first place and doesn't
         take care of all device-size-related changes we might like to make
     */
    func numPointsIfCompactSizeDevice(descriptors: PageDescriptors,
                                      deviceType: PlatformSpecifics.SizeClass) -> Int {
        if deviceType == .compact {
            switch descriptors.pageType {
                case .circle : return descriptors.numPoints
                case .classicSE : return 34
                case .deltaWing : return descriptors.numPoints
                case .rorschach : return 23
            }
        }
        return descriptors.numPoints
    }
    
    @EnvironmentObject var colorScheme : ColorScheme
    
//  played w/ a version where even and odd vertex markers changed color
//  between .zig and .zag cycles. effect did not warrant the complexity.
    
//    func adjustMarkerColors(for blobPhase: BlobPhase ) {
//
//        // 2check that colorScheme.evenNumberedVertices & .oddNumberVertices
//        // initial color assignment in BezierBlobsApp is same as .zigColor here
//
//        let zigColor = BezierBlobsApp.initialOddAndEvenVertexMarkersColor
//        let zagColor = Color.yellow
//
//        switch blobPhase {
//            case .zig:
//                colorScheme.oddNumberedVertices = zigColor
//                colorScheme.evenNumberedVertices = zigColor
//            case .zag:
//                colorScheme.oddNumberedVertices = zagColor
//                colorScheme.evenNumberedVertices = zagColor
//        }
//    }
    
    var body: some View {
    
        ZStack {

            colorScheme.background
            
            SELayersStack(model: self.model)
        }
        //MARK: - onAppear()
        .onAppear {
            if DEBUG.TRACE_MAIN_ANIMATION_EVENTS {
                print("\nPageView.onAppear{ PageType.\(descriptors.pageType) }")
            }
        }
        
        .onDisappear {
            animationTimer.cancel()
        }
    
        //MARK: onReceive()
        .onReceive(animationTimer.timer) { _ in
            
            //adjustMarkerColors(for: model.blobPhase)

            // this is for the orbiting-vertex animation.
            // the animation duration is set faster. because we can.
            withAnimation(PageView.animationQuickMarchStyle) {
                
                if layers.isVisible(layerType: .animatingOrbitalMarkers) {
                    
                    model.animateToNextOrbitalMarkersConfiguration()
                }
            }
            // for any of our "standard" blob-perturbation animations
            withAnimation(PageView.animationNormalStyle) {
                
                // TBD: is this check actually worth doing???
                
                if layers.anyBlobAnimationLayerIsVisible() {
                    
                    switch options.currPerturbStrategy {

                        case .staticZigZags :
                            model.animateToNextFixedPerturbationDelta()
                            
                        case .randomizedZigZags :
                            model.animateToNextRandomizedPerturbationDelta()
                    }
                }
            }
            
            model.blobPhase.nextPhase()
            animationTimer.restart()
        }
        
        //MARK: onTapGesture(2)
        .onTapGesture(count: 2) {
            
            if DEBUG.TRACE_MAIN_ANIMATION_EVENTS {
                print( "PageView.onTapGesture(2). ANIMATION -- REVERT TO INITIAL CONFIGURATION")
            }
            
            withAnimation(PageView.animationQuickMarchStyle)
            {
                animationTimer.cancel()
                
                model.returnToInitialConfiguration()
                //adjustMarkerColors(for: model.blobPhase)
            }
        }
        
        // MARK: onTapGesture(1)
        .onTapGesture(count: 1)
        {
            // if either chooser view is visible, dismiss it
            
            if showLayersList || showMiscOptionsList {
                showLayersList = false;
                showMiscOptionsList = false
            }
            else {
                if !animationTimer.isAnimating {
                    
                    if DEBUG.TRACE_MAIN_ANIMATION_EVENTS {
                        print( "PageView.onTapGesture(1): ANIMATING START")
                    }
                    animationTimer.start()
                }
                else {
                    if DEBUG.TRACE_MAIN_ANIMATION_EVENTS {
                        print( "PageView.onTapGesture(1): ANIMATING STOP")
                    }
                    animationTimer.cancel()
                }
            }
        }
        .overlay(displaySuperEllipseMetrics(numPoints: numPoints))
        
//        .displayScreenSizeMetrics(frontColor: Color.init(white: 0.25),
//                                  backColor: .init(white: 0.8))
//        .overlay(bullseye(color: .red))
        .overlay(
            MainScreenUI(showLayersList : $showLayersList,
                         showMiscOptionsList: $showMiscOptionsList,
                         deviceType: deviceSizeClass)
        )
    }
    
    //MARK: -
    func displaySuperEllipseMetrics(numPoints: Int) -> some View {
        VStack(spacing: 3) {
            DropShadowedText(text: "numPoints: \(numPoints)",
                             font: .headline,
                             weight: .light,
                             foreColor: .white,
                             backColor: .init(white: 0.2))
            DropShadowedText(text: "n: \(descriptors.n.format(fspec: "3.1"))",
                             font: .headline,
                             weight: .light,
                             foreColor: .white,
                             backColor: .init(white: 0.2))
        }
    }
}

//MARK:-
struct DropShadowedText : View {
    var text: String
    let font: Font
    let weight: Font.Weight
    var foreColor: Color
    var backColor: Color
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Text(text)
                    .font(font)
                    .fontWeight(weight)
                    .foregroundColor(backColor)
                    .offset(x: 2, y: 2)
                Text(text)
                    .font(font)
                    .fontWeight(weight)
                    .foregroundColor(foreColor)
            }
        }
    }
}

//MARK:-
struct PageGradientBackground : View {
    let colors : [Color] = [.init(white: 0.9), .init(white: 0.3)]
    var body : some View {
        
        LinearGradient(gradient: Gradient(colors: colors),
                       startPoint: .bottomLeading,
                       endPoint: .topTrailing)
    }
}

//MARK:-
//;
