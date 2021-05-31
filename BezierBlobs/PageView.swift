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
    case mutantMoth = "PHANTASM"
}

typealias PageDescription
                = (numPoints: Int,
                   n: Double,
                   axisRelOffsets: (inner: CGFloat, baseCurve: Double, outer: CGFloat),
                   relativeDeltas: RelativePerturbationRanges,
                   blobLimits: (inner: CGFloat, outer: CGFloat),
                   forceEqualAxes: Bool)

struct PageView: View {
        
    let pageDesc: PageDescription
    
    static let descriptions : [PageDescription] =
    [
    // CLASSIC SE
        (numPoints: 28,
         n: 3.0,
         axisRelOffsets: (inner: 0.4, baseCurve: 0.5, outer: 0.8),
         relativeDeltas: (innerRange: -0.1..<0.2,
                          outerRange: -0.15..<0.15),
         blobLimits: (inner: 1.0, outer: 0.8), false),
        
    // CIRCLE
            (numPoints: 22,
             n: 2.0,
             axisRelOffsets: (inner: 0.25, baseCurve: 0.5, outer: 0.75),
             relativeDeltas: (innerRange: 0..<0.3,
                                          outerRange: -0.3..<0.3),
             blobLimits: (inner: 0.5, outer: 0.5),
             forceEqualAxes: true),

    // DELTA WING
        (numPoints: 6,
         n: 3,
        axisRelOffsets: (inner: 0.15, baseCurve: 0.5, outer: 0.8),
        relativeDeltas: (innerRange: 0..<0.3,
                                     outerRange: -0.3..<0.3),
        blobLimits: (inner: 0.0, outer: 0.0), false),
        
    // PHANTASM
        (numPoints: 22,
         n: 1,
         axisRelOffsets: (inner: 0.5, baseCurve: 0.6, outer: 0.85),
         relativeDeltas: (innerRange: -0.1..<0.25,
                                      outerRange: -0.35..<0.2),
         blobLimits: (inner: 3.0, outer: 0.8), false)
    ]
            
    @ObservedObject var model = Model()
    
    @EnvironmentObject var layers : SELayersViewModel
    @EnvironmentObject var options : MiscOptionsModel
    @EnvironmentObject var colorScheme : ColorScheme
    
    //MARK:-
    // timerTimeIncrement - animationTimeIncrement
    // == time paused between animations
    
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
        
        print("   semiMinorAxis a: {\(a)} semiMajorAxis b: {\(b)}")
        
        let baseCurveRatio = pageDesc.axisRelOffsets.baseCurve
        let baseCurve = minAxis * CGFloat(baseCurveRatio)
        
        let offsets: Offsets = (inner: (minAxis * pageDesc.axisRelOffsets.inner - baseCurve),
                                outer: minAxis * pageDesc.axisRelOffsets.outer - baseCurve)
        
        let blobLimits : ZigZagDeltas = (inner: abs(pageDesc.blobLimits.inner * offsets.inner),
                                         outer: abs(pageDesc.blobLimits.outer * offsets.outer))
        model.offsets = offsets
        model.blobLimits = blobLimits

        let innerRange = pageDesc.relativeDeltas.innerRange
        let outerRange = pageDesc.relativeDeltas.outerRange
        
        let innerScreenRange = innerRange.lowerBound * minAxis..<innerRange.upperBound * minAxis
        let outerScreenRange = outerRange.lowerBound * minAxis..<outerRange.upperBound * minAxis
        let perturbationDeltas : PerturbationRanges = (innerRange: innerScreenRange,
                                                       outerRange: outerScreenRange)
        
        model.perturbationRanges = perturbationDeltas
        
        if Model.DEBUG_ADJUST_PERTURBATION_LIMITS {
            print("   baseCurve.ratio: {\(baseCurveRatio.format(fspec: "4.2"))}" +
                    " => {\(baseCurve.format(fspec: "4.2"))}")
            
            print("   axisRelativeOffsets: (inner: \(pageDesc.axisRelOffsets.inner.format(fspec: "4.2")), " +
                "outer: \(pageDesc.axisRelOffsets.outer.format(fspec: "4.2"))) => "
            
                + "offsets: {(inner: \(offsets.inner) outer: \(offsets.outer))}")
            
            print("   blobLimits : " +
                    "(inner: {+/- \(model.blobLimits.inner.format(fspec: "4.2"))}, " +
                    "outer: {+/- \(model.blobLimits.outer.format(fspec: "4.2"))}) ")
        }
        
        print("model.calculateSuperEllipse()")
        model.calculateSuperEllipse(for: pageType,
                                    pageDescription: pageDesc,
                                    axes: (a: a * baseCurveRatio,
                                           b: b * baseCurveRatio)
        )
        model.calculateSupportCurves()
    }
    
    struct PageGradientBackground : View {
        let colors : [Color] = [.init(white: 0.9), .init(white: 0.3)]
        var body : some View {
            
            LinearGradient(gradient: Gradient(colors: colors),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
//            Color.orange
        }
    }
    
    var body: some View {
    
        ZStack {

//            PageGradientBackground()
            Color.init(white: 0.75)
                        
    //MARK:- DISPLAY THE FOLLOWING LAYERS IF FLAGGED
            
        // SUPPORT LAYERS //
        // --------------------------------------------------------------
            if layers.isVisible(layerWithType: .normals) {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   style: markerStyles[.envelopeBounds]!)
            }
            
            // OUTSIDE offsets visible as a bottom layer
            if layers.isVisible(layerWithType: .offsetsEnvelope) {
                EnvelopeBounds(curves: model.boundingCurves,
                               style: markerStyles[.envelopeBounds]!,
                               showInnerOffset: false,
                               showOuterOffset: true)
            }
            
            // ANIMATING BLOB LAYERS //
            // --------------------------------------------------------------
            
            // just for fun we use an @EnvironmentObject-injected
            // layers object for this one. see AnimatingBlob_Filled().
            
                AnimatingBlob_Filled(curve: model.blobCurve,
                                     layerType: .blob_filled)

                if layers.isVisible(layerWithType: .blob_stroked) {
                    AnimatingBlob_Stroked(curve: model.blobCurve)
                }
            
            if layers.isVisible(layerWithType: .baseCurve_and_markers) {
                BaseCurve_And_Markers(curve: model.baseCurve.map{ $0.vertex },
                                      style: markerStyles[.baseCurve]!)
            }
            
            if layers.isVisible(layerWithType: .offsetsEnvelope) {
                EnvelopeBounds(curves: model.boundingCurves,
                               style: markerStyles[.envelopeBounds]!,
                               showInnerOffset: true,
                               showOuterOffset: false)
            }
            
        // MORE ANIMATING BLOB LAYERS //
        // --------------------------------------------------------------
            
            if layers.isVisible(layerWithType: .blob_markers) {
                AnimatingBlob_Markers(curve: model.blobCurve,
                                      style: markerStyles[.blob]!)
            }
            
            if layers.isVisible(layerWithType: .blob_vertex_0_marker) {
                AnimatingBlob_VertexZeroMarker(animatingCurve: model.blobCurve,
                                               markerStyle: markerStyles[.vertexOrigin]!)
            }
            
        }
        
        // an interesting bug occurs if we use .background(...) instead of
        // PageGradientBackground() as above, and then select 'hide all layers'
        // .background(colorScheme.background)

        .onDisappear {
            isAnimating = false
            timer.connect().cancel()
        }
    
        //MARK: onReceive()
        .onReceive(timer) { _ in
            
            withAnimation(PageView.animationStyle) {
                
                switch options.currPerturbStrategy {
                
                case .staticZigZags :
                    model.animateToNextFixedZigZag()
                    
                case .randomizedZigZags :
                    model.animateToRandomizedPerturbationInRange()
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
