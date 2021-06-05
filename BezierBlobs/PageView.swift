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
    case mutantMoth = "RORSCHACH"
}

typealias PageDescription
                = (n: Double,
                   numPoints: Int,
                   axisRelOffsets: (inner: CGFloat, baseCurve: Double, outer: CGFloat),
                   axisRelDeltas: AxisRelativePerturbationDeltas,
                   forceEqualAxes: Bool)

struct PageView: View {
        
    let descriptors: PageDescription
    
    static let NIL_RANGE : Range<CGFloat>
                = 0..<CGFloat(SEParametrics.VANISHINGLY_SMALL_DOUBLE)
    
    static let descriptions : [PageDescription] =
    [
    // CIRCLE
        // NOTA: INTERESTING THINGS can happen when axisRelOffsets.inner is > 1.
        // NOTE as well that the upper end of 'nil' ranges MUST be larger
        // than its lower end ...
        
        // some rather bizarre-type effects. interesting
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
    
    //MARK:- PageView.INIT
    init(pageType: PageType, descriptors: PageDescription, size: CGSize) {
        
        print("\n")
        print("PageView.init( {PageType.\(pageType)} ): \n" +
                "   numPoints: {\(descriptors.numPoints)} {w: \((size.width).format(fspec: "4.2")), h: \((size.height).format(fspec: "4.2"))}")
        
        if Model.DEBUG_PRINT_PAGEVIEW_INIT_BASIC_AXIS_PARAMS {
            print("PageView.init(pageType.\(pageType.rawValue))")
            print ("PageView.init(). screen size   = W: {\(size.width)}, H: {\(size.height)}")
            print ("PageView.init(). semiAxis size = W: {\((size.width/2).format(fspec: "4.2"))} H: {\((size.height/2).format(fspec: "4.2"))}")
        }
        
        self.pageType = pageType
        self.descriptors = descriptors
        
        let (a, b) = axesFor(size: size, forceEqualAxes: descriptors.forceEqualAxes)
                
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
        
        print("   semiMinorAxis a: [\(a)] semiMajorAxis b: [\(b)]\n")
        print("   model.offsets : " +
                "(inner: [\(model.offsets.inner.format(fspec: "4.2"))] <—-|-—> " +
                "outer: [\(model.offsets.outer.format(fspec: "4.2"))]) ")
        
        print("   perturbationRanges: inner: (\(innerRange.lowerBound)..< \(innerRange.upperBound)) <—-|-—> " +
              "outer: (\(outerRange.lowerBound)..< \(outerRange.upperBound))")
                
//        print("   perturbRanges: inner: (\(innerRange.lowerBound) ..< \(innerRange.upperBound) )\n" +
//              "                  outer: (\(outerRange.lowerBound) ..< \(outerRange.upperBound) )")
        
        model.calculateSuperEllipse(for: pageType,
                                    n: descriptors.n,
                                    numPoints: descriptors.numPoints,
                                    axes: (a: a * baseCurveRatio,
                                           b: b * baseCurveRatio)
        )
        
        model.calculateSupportCurves()
    }
    
    var body: some View {
    
        ZStack {

            PageGradientBackground()
//            Color.init(white: 0.75)
                        
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
                OffsetsEnvelope(curves: model.boundingCurves,
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
                OffsetsEnvelope(curves: model.boundingCurves,
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
            DropShadowedText(text: "numPoints: \(descriptors.numPoints)",
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
    let colors : [Color] = [.init(white: 0.3), .init(white: 0.95)]
    var body : some View {
        
        LinearGradient(gradient: Gradient(colors: colors),
                       startPoint: .bottomLeading,
                       endPoint: .topTrailing)
    }
}

//MARK:-

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pageType: PageType.circle, descriptors: PageView.descriptions[0], size: CGSize(width: 650, height: 550))
    }
}
