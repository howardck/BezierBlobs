//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

enum PageType : String {
    case circle = "CIRCLE"
    case superEllipse = "CLASSIC SE"
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
        
    let descriptors: PageDescription
    //@State var numPoints
    
    static let NIL_RANGE : Range<CGFloat>
                = 0..<CGFloat(SEParametrics.VANISHINGLY_SMALL_DOUBLE)
    
    static let descriptions : [PageDescription] =
    [
    // CIRCLE
        // NOTA: INTERESTING THINGS can happen when axisRelOffsets.inner is > 1.
        // NOTE as well that the upper end of 'nil' ranges MUST be larger
        // than its lower end ...
        
        // some rather BIZARRE-type effects. interesting
        // NIL_RANGE : Range<CGFloat> = 0..<CGFloat(Parametrics.VANISHINGLY_SMALL_DOUBLE)
        //        (n: 2.0,
        //         numPoints: 16,
        //         axisRelOffsets: (inner: 0.1, baseCurve: 0.5, outer: 1.0),
        //         axisRelDeltas: (innerRange: NIL_RANGE,
        //                         outerRange: -0.6..<0.4),
        //         forceEqualAxes: true),
        
        
        // GOOD ...
        (n: 2.0, numPoints: 22,
         axisRelOffsets: (inner: 0.25, baseCurve: 0.5, outer: 0.75),
         axisRelDeltas: (innerRange: 0..<0.3, outerRange: -0.3..<0.3),
         forceEqualAxes: true),
        
        // TESTING VISUAL DISPLAY OF PERTURBATION DELTA "BANDING"
        
//        (n: 2.0, numPoints: 8,
//         axisRelOffsets: (inner: 0.25, baseCurve: 0.5, outer: 0.75),
//         axisRelDeltas: (innerRange: -0.15..<0.1, outerRange: -0.2..<0.2),
//         forceEqualAxes: true),
        
    // CLASSIC SE
        (n: 3.0, numPoints: 28,
         axisRelOffsets: (inner: 0.4, baseCurve: 0.5, outer: 0.8),
         axisRelDeltas: (innerRange: -0.1..<0.2, outerRange: -0.15..<0.15),
         forceEqualAxes: false),

    // DELTA WING
        (n: 3, numPoints: 6,
        axisRelOffsets: (inner: 0.15, baseCurve: 0.5, outer: 0.8),
        axisRelDeltas: (innerRange: 0..<0.3, outerRange: -0.3..<0.3),
        forceEqualAxes: false),
        
    // RORSCHACH
        (n: 1, numPoints: 22,
         axisRelOffsets: (inner: 0.5, baseCurve: 0.6, outer: 0.85),
         axisRelDeltas: (innerRange: -0.1..<0.25, outerRange: -0.35..<0.2),
         forceEqualAxes: false)
    ]
            
    @ObservedObject var model = Model()
    
    @EnvironmentObject var layers : SELayersViewModel
    @EnvironmentObject var options : MiscOptionsModel
    @EnvironmentObject var colorScheme : ColorScheme
    
    //MARK:-
    // timerTimeInc - animationTimeInc == time paused between animations
    
    static let timerTimeIncrement : Double = 2.8
    static let animationTimeIncrement : Double = 2.6
    static let timerInitialTimeIncrement : Double = 0.0
    static let animationStyle = Animation.easeOut(duration: PageView.animationTimeIncrement)
    
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
        
        //print("\n")
        print("PageView.init( {PageType.\(pageType)} ): \n" +
                "   numPoints: {\(descriptors.numPoints)} {w: \((size.width).format(fspec: "4.2")), h: \((size.height).format(fspec: "4.2"))}")
        
        print("PageView.deviceType: {\(deviceType)}")
        
        if Model.DEBUG_PRINT_PAGEVIEW_INIT_BASIC_AXIS_PARAMS {
            print("PageView.init(pageType.\(pageType.rawValue))")
            print ("PageView.init(). screen size   = W: {\(size.width)}, H: {\(size.height)}")
            print ("PageView.init(). semiAxis size = W: {\((size.width/2).format(fspec: "4.2"))} H: {\((size.height/2).format(fspec: "4.2"))}")
        }
        
        self.pageType = pageType
        self.descriptors = descriptors
        
        let (a, b) = axesFor(size: size,
                             forceEqualAxes: descriptors.forceEqualAxes)
                
        let minAxis = CGFloat(min(a, b))
        let baseCurveRatio = descriptors.axisRelOffsets.baseCurve
        let baseCurve = minAxis * CGFloat(baseCurveRatio)

        model.offsets = (inner: (minAxis * descriptors.axisRelOffsets.inner - baseCurve),
                         outer: minAxis * descriptors.axisRelOffsets.outer - baseCurve)

        let relInRange = descriptors.axisRelDeltas.innerRange
        let relOutRange = descriptors.axisRelDeltas.outerRange
        
        let innerRange = (relInRange.lowerBound * minAxis)..<(relInRange.upperBound * minAxis)
        let outerRange = (relOutRange.lowerBound * minAxis)..<(relOutRange.upperBound * minAxis)
        
        let pRanges : PerturbationDeltas = (innerRange: innerRange,
                                            outerRange: outerRange)
        model.perturbationDeltas = pRanges
        
        print("   semiMinorAxis a: [\(a)] semiMajorAxis b: [\(b)]")
        print("   model.offsets : " +
                "(inner: [\(model.offsets.inner.format(fspec: "4.2"))] <—-|-—> " +
                "outer: [\(model.offsets.outer.format(fspec: "4.2"))]) ")
        
        print("   perturbationRanges: inner: (\(innerRange.lowerBound)..< \(innerRange.upperBound)) <—-|-—> " +
              "outer: (\(outerRange.lowerBound)..< \(outerRange.upperBound))")
        
        //FIXME: NEW numPoints DOESN'T UPDATE OVERLAY
    
        numPoints = descriptors.numPoints
        
        // WARNING: KLUDGE AHEAD!
        if deviceType == .compact && pageType == .circle {
            numPoints = Int(Double(numPoints) * 0.8)
        }
        else if deviceType == .compact && pageType == .superEllipse {
            numPoints = Int(Double(numPoints) * 0.8)
        }

        model.calculateSuperEllipse(for: pageType,
                                    n: descriptors.n,
                                    numPoints: numPoints,
                                    axes: (a: a * baseCurveRatio,
                                           b: b * baseCurveRatio)
        )
        model.calculateSupportCurves()
    }
    
    var body: some View {
    
        ZStack {

            PageGradientBackground()
            //Color.init(white: 0.75)
            
            SELayersVisibilityToggles(model: self.model)
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
            
            print("\nPageView.onReceive(timer){ PageType.\(pageType) }")
            
            withAnimation(PageView.animationStyle) {
                
                switch options.currPerturbStrategy {
                
                case .staticZigZags :
                    print("PageView.onReceive(): calling model.animateToNextFixedPerturbationDelta()")
                    model.animateToNextFixedPerturbationDelta()
                    
                case .randomizedZigZags :
                    print("PageView.onReceive(): calling model.animateToRandomizedPerturbation()")
                    model.animateToRandomizedPerturbation()
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
