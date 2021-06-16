//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

enum PageType : String {
    case circle = "CIRCLE"
    case classicSE = "CLASSIC SE"
    case deltaWing = "DELTA WING"
    case rorschach = "RORSCHACH"
}

typealias PageDescription
                = (n: Double,
                   numPoints: Int,
                   axisRelOffsets: (inner: CGFloat, baseCurve: Double, outer: CGFloat),
                   axisRelDeltas: AxisRelativePerturbationDeltas,
                   forceEqualAxes: Bool)

struct PageView: View {
    
    //MARK:-
    // timerTimeInc - animationTimeInc == time paused between animations
    static let timerTimeIncrement : Double = 3.8
    static let animationTimeIncrement : Double = 2.4
    static let timerInitialTimeIncrement : Double = 0.0

    static let animationStyle = Animation.easeOut(duration: PageView.animationTimeIncrement)
    
    static let NIL_RANGE : Range<CGFloat>
                = 0..<CGFloat(SEParametrics.VANISHINGLY_SMALL_DOUBLE)
    
    let descriptors: PageDescription

    static let descriptions : [PageDescription] =
    [
    // CIRCLE
        // NOTA: interesting things can happen when axisRelOffsets.inner is > 1.
        // NOTE as well that the upper end of 'nil' ranges
        // must be larger than the lower end.
        // also interesting:
//        (n: 2.0,
//         numPoints: 16,
//         axisRelOffsets: (inner: 0.1, baseCurve: 0.5, outer: 1.0),
//         axisRelDeltas: (innerRange: NIL_RANGE,
//                         outerRange: -0.6..<0.4),
//         forceEqualAxes: true),
        
    // CIRCLE
        (n: 2.0, numPoints: 30,
         axisRelOffsets: (inner: 0.4, baseCurve: 0.6, outer: 0.8),
         axisRelDeltas: (innerRange: -0.1..<0.15, outerRange: -0.3..<0.1),
         forceEqualAxes: true),
        
    // CLASSIC SE
//        (n: 3.5, numPoints: 36,
//         axisRelOffsets: (inner: 0.4, baseCurve: 0.5, outer: 0.7),
//         axisRelDeltas: (innerRange: -0.1..<0.2, outerRange: -0.2..<0.2),
//         forceEqualAxes: false),
        
        // rel offsets & deltas calc'ed/brought over from nice-looking
        // BezierBlob example
        (n: 2.8, numPoints: 34,
         axisRelOffsets: (inner: 0.45, baseCurve: 0.6, outer: 0.85),
         axisRelDeltas: (innerRange: -0.1..<0.2, outerRange: -0.2..<0.1),
         forceEqualAxes: false),
        
//        (n: 3.0, numPoints: 28,
//         axisRelOffsets: (inner: 0.4, baseCurve: 0.5, outer: 0.8),
//         axisRelDeltas: (innerRange: -0.15..<0.2, outerRange: -0.15..<0.15),
//         forceEqualAxes: false),

    // DELTA WING
        (n: 3, numPoints: 6,
        axisRelOffsets: (inner: 0.2, baseCurve: 0.4, outer: 0.75),
        axisRelDeltas: (innerRange: -0.1..<0.1, outerRange: -0.25..<0.25),
        forceEqualAxes: false),
        
    // RORSCHACH
        (n: 0.8, numPoints: 26,
         axisRelOffsets: (inner: 0.35, baseCurve: 0.6, outer: 0.8),
         axisRelDeltas: (innerRange: 0.1..<0.10001, outerRange: -0.25..<0.25),
//         axisRelOffsets: (inner: 0.4, baseCurve: 0.65, outer: 0.9),
//         axisRelDeltas: (innerRange: 0..<0.4, outerRange: -0.4..<0.4),
         forceEqualAxes: false)
      
//        axisRelOffsets: (inner: 0.25, baseCurve: 0.5, outer: 0.7),
//        axisRelDeltas: (innerRange: -0.1..<0.3, outerRange: -0.3..<0.3),
//        forceEqualAxes: false)
        
//        (n: 1, numPoints: 22,
//         axisRelOffsets: (inner: 0.5, baseCurve: 0.6, outer: 0.85),
//         axisRelDeltas: (innerRange: -0.1..<0.25, outerRange: -0.35..<0.2),
//         forceEqualAxes: false)
    ]
            
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
    
    var randomPermutations = true
        
    var pageType: PageType
    
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
    init(pageType: PageType,
         descriptors: PageDescription,
         size: CGSize,
         deviceType: PlatformSpecifics.SizeClass) {
        
        //TODO: TODO: move to a separate DEBUG function invoked here
        print("PageView.init( {PageType.\(pageType)} ): \n" +
                "   numPoints: {\(descriptors.numPoints)} {" +
                "w: \((size.width).format(fspec: "4.2")), " +
                "h: \((size.height).format(fspec: "4.2"))}")
        
        print("PageView.deviceType: {\(deviceType)}")
        
        if Model.DEBUG_PRINT_PAGEVIEW_INIT_BASIC_AXIS_PARAMS {
            print("PageView.init(pageType.\(pageType.rawValue))")
            print ("PageView.init(). screen size   = " +
                    "W: {\(size.width)}, H: {\(size.height)}")
            print ("PageView.init(). semiAxis size = " +
                    "W: {\((size.width/2).format(fspec: "4.2"))} H: {\((size.height/2).format(fspec: "4.2"))}")
        }
        
        self.pageType = pageType
        self.descriptors = descriptors
        
        let (a, b) = axesFor(size: size,
                             forceEqualAxes: descriptors.forceEqualAxes)
                
        print("   semiMinorAxis a: [\(a)] semiMajorAxis b: [\(b)]")

        let baseCurveRatio = descriptors.axisRelOffsets.baseCurve
        let minAxis = CGFloat(min(a, b))
        let baseCurve = minAxis * CGFloat(baseCurveRatio)
        
        model.offsets = (inner: (minAxis * descriptors.axisRelOffsets.inner - baseCurve),
                         outer: minAxis * descriptors.axisRelOffsets.outer - baseCurve)

        model.calculatePerturbationDeltas(descriptors: descriptors, minAxis: minAxis)

        // KLUDGE? easier than setting up a parallel descriptors dict for iphone
        numPoints = numPointsAdjustedForCompactSizeDevices(descriptors: descriptors,
                                                           deviceType: deviceType)
        model.calculateSuperEllipse(for: pageType,
                                    n: descriptors.n,
                                    numPoints: numPoints,
                                    axes: (a * baseCurveRatio, b * baseCurveRatio)
        )
        
        model.calculateSupportCurves()
    }
    
    func numPointsAdjustedForCompactSizeDevices(descriptors: PageDescription,
                                                deviceType: PlatformSpecifics.SizeClass) -> Int {
        if deviceType == .compact && (pageType == .circle || pageType == .classicSE) {
            return Int(Double(descriptors.numPoints) * 0.85)
        }
        return descriptors.numPoints
    }
    
    func DEBUG_printDescriptors(_ pageType: PageType,
                                _ descriptors: PageDescription,
                                _ size: CGSize,
                                _ deviceType: PlatformSpecifics.SizeClass) {

        print("PageView.init( {PageType.\(pageType)} ): \n" +
                "   numPoints: {\(descriptors.numPoints)} {w: \((size.width).format(fspec: "4.2")), h: \((size.height).format(fspec: "4.2"))}")
        
        print("PageView.deviceType: {\(deviceType)}")
        
        if Model.DEBUG_PRINT_PAGEVIEW_INIT_BASIC_AXIS_PARAMS {
            print("PageView.init(pageType.\(pageType.rawValue))")
            print ("PageView.init(). screen size   = W: {\(size.width)}, H: {\(size.height)}")
            print ("PageView.init(). semiAxis size = W: {\((size.width/2).format(fspec: "4.2"))} H: {\((size.height/2).format(fspec: "4.2"))}")
        }
    }
    
    var body: some View {
    
        ZStack {

            PageGradientBackground()
            
            // per-layer visibility turned on & off according to settings
            // in the layers view model, these in responding to
            // selections make by the suer in the layers chooser.
            
            SELayersVisibilityStack(model: self.model)
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
            DropShadowedText(text: "n: \(descriptors.n.format(fspec: "3.1"))",
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
