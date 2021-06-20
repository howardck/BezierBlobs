//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

struct PageView: View {
    
    //MARK:-
    // timerTimeInc - animationTimeInc == time paused between animations
    static let timerTimeIncrement : Double = 3.2
    static let animationTimeIncrement : Double = 2.0
    static let timerInitialTimeIncrement : Double = 0.0

    static let animationStyle = Animation.easeOut(duration: PageView.animationTimeIncrement)
    
    static let NIL_RANGE : Range<CGFloat>
                = 0..<CGFloat(SEParametrics.VANISHINGLY_SMALL_DOUBLE)
    
    let descriptors: PageDescriptors
            
    @ObservedObject var model = Model()
    
    @EnvironmentObject var layers : SELayersViewModel
    @EnvironmentObject var options : MiscOptionsModel
    @EnvironmentObject var colorScheme : ColorScheme
    
    //MARK:-
    @State var showLayersList = false
    @State var showMiscOptionsList = false
    
    @State var timer: Timer.TimerPublisher
                            = Timer.publish(every: PageView.timerTimeIncrement,
                                            on: .main, in: .common)
    @State var isAnimating = false
    @State var isFirstTappedCycle = true
        
    var pageType: PageDescriptors.PageType
    
    //MARK:-
    func axesFor(size: CGSize, forceEqualAxes: Bool) -> (a: Double, b: Double) {
        var a = Double(size.width/2)
        var b = Double(size.height/2)
        if forceEqualAxes {
            a = min(a, b)
            b = min(a, b)
        }
        return (a, b)
    }
    
    var numPoints : Int = 0
    
    //MARK:- PageView.INIT
    init(descriptors: PageDescriptors,
         size: CGSize,
         deviceType: PlatformSpecifics.SizeClass) {
        
        self.pageType = descriptors.pageType
        self.descriptors = descriptors
        
        let (a, b) = axesFor(size: size,
                             forceEqualAxes: descriptors.forceEqualAxes!)
        
        if DEBUG.PRINT_BASIC_PAGE_INFO {
            DEBUG.printBasicPageInfo(pageType: pageType,
                                     numPoints: descriptors.numPoints,
                                     size: size,
                                     axes: (a, b))
        }

        let baseCurveRatio = descriptors.axisRelOffsets.baseCurve
        let minAxis = CGFloat(min(a, b))
        let baseCurve = minAxis * CGFloat(baseCurveRatio)
        
        // convert from semiminor-axis-relative ratios to absolute screen distances
        model.offsets = (inner: minAxis * descriptors.axisRelOffsets.inner - baseCurve,
                         outer: minAxis * descriptors.axisRelOffsets.outer - baseCurve)

        model.calculatePerturbationDeltas(descriptors: descriptors, minAxis: minAxis)
        
        if DEBUG.PRINT_OFFSET_AND_PERTURBATION_DATA {
            DEBUG.printOffsetAndPerturbationData(pageType: descriptors.pageType,
                                                 offsets: model.offsets,
                                                 ranges: model.perturbationDeltas)
        }
        // KLUDGEY? easier than setting up a parallel descriptors dict for compact devices
        numPoints = downsizeNumPointsForCompactSizeDevices(descriptors: descriptors,
                                                           deviceType: deviceType)
        model.calculateSuperEllipse(n: descriptors.order,
                                    numPoints: numPoints,
                                    axes: (a * baseCurveRatio, b * baseCurveRatio) )
        model.calculateSupportCurves()
    }
    
    func downsizeNumPointsForCompactSizeDevices(descriptors: PageDescriptors,
                                                deviceType: PlatformSpecifics.SizeClass) -> Int {
        if deviceType == .compact && (pageType == .circle || pageType == .classicSE) {
            return Int(Double(descriptors.numPoints) * 0.85)
        }
        return descriptors.numPoints
    }
    
//    func DEBUG_printDescriptors(_ pageType: PageDescriptors.PageType,
//                                _ descriptors: PageDescriptors,
//                                _ size: CGSize,
//                                _ deviceType: PlatformSpecifics.SizeClass) {
//
//        print("PageView.init( {PageType.\(pageType)} ): \n" +
//                "   numPoints: {\(descriptors.numPoints)} {w: \((size.width).format(fspec: "4.2")), h: \((size.height).format(fspec: "4.2"))}")
//
//        print("PageView.deviceType: {\(deviceType)}")
//
//        if Model.DEBUG_PRINT_PAGEVIEW_INIT_BASIC_AXIS_PARAMS {
//            print("PageView.init(pageType.\(pageType.rawValue))")
//            print ("PageView.init(). screen size   = W: {\(size.width)}, H: {\(size.height)}")
//            print ("PageView.init(). semiAxis size = W: {\((size.width/2).format(fspec: "4.2"))} H: {\((size.height/2).format(fspec: "4.2"))}")
//        }
//    }
    
    var body: some View {
    
        ZStack {

            PageGradientBackground()
            
            // per-layer visibility turned on & off according to settings
            // in the layers view model, these in responding to
            // selections make by the suer in the layers chooser.
            
            SELayerGroupsVisibility(model: self.model)
        }
        //MARK:- onAppear()
        .onAppear {
            print("\nPageView.onAppear{ PageType.\(pageType) }")
        }
        
        .onDisappear { 
            isAnimating = false
            timer.connect().cancel()
        }
    
        //MARK: onReceive()
        .onReceive(timer) { _ in
            
            withAnimation(PageView.animationStyle) {
                
                switch options.currPerturbStrategy {

                case .staticZigZags :
                    
                    model.animateToNextFixedPerturbationDelta()

                case .randomizedZigZags :

                    model.animateToNextRandomizedPerturbationDelta()
                }
            }

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
            print("PageView.onTapGesture(1) { PageType.\(pageType) }")
            
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
        .overlay(displaySuperEllipseMetrics(numPoints: numPoints))
        .displayScreenSizeMetrics(frontColor: .black, backColor: .init(white: 0.7))
        .overlay(
            MainScreenUI(showLayersList : $showLayersList,
                         showMiscOptionsList: $showMiscOptionsList)
        )
    }
    
    func displaySuperEllipseMetrics(numPoints: Int) -> some View {
        VStack(spacing: 10) {
            DropShadowedText(text: "numPoints: \(numPoints)",
                             foreColor: .white,
                             backColor: .init(white: 0.2))
            DropShadowedText(text: "n: \(descriptors.order.format(fspec: "3.1"))",
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
