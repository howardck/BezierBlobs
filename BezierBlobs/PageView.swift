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
    case mutantMoth = "MUTANT MOTH"
}

typealias PageDescription = (numPoints: Int,
                             n: Double,
                             baseCurveRatio: Double,
                             offsets: (in: CGFloat, out: CGFloat),  // it's either THIS
                             axisRelOffsets: (inner: CGFloat, outer: CGFloat), // or THIS
                             blobLimits: BlobPerturbationLimits,
                             forceEqualAxes: Bool)
struct PageView: View {
        
    let description: PageDescription
    //let s: CGSize
    
    static let descriptions : [PageDescription] =
    [
        // CLASSIC
        (numPoints: 20,
         n: 3.8,
         baseCurveRatio: 0.75,
         offsets: (in: -0.25, out: 0.25), // old style
         axisRelOffsets: (inner: 0.2, outer: 0.2), // new style
         blobLimits: (inner: 0.6, outer: 1.0), false),
        
        // CIRCLE
        (numPoints: 12,
         n: 2.0,
         baseCurveRatio: 1,
         offsets: (in: -0.33, out: 0.33), // old style
         axisRelOffsets: (inner: 0.1, outer: 0.1), // new style
         blobLimits: (inner: 0.75, outer: 1.0),
         forceEqualAxes: true),
        
//        (numPoints: 14, n: 2.0,
//         offsets: (in: -0.25, out: 0.25), blobLimits: (inner: 0.75, outer: 1.0),
//         forceEqualAxes: true),
        
        // DELTA WING
        (numPoints: 6,
         n: 3,
         baseCurveRatio: 0.5,
         offsets: (in: -0.45, out: 0.35),
         axisRelOffsets: (inner: 0.1, outer: 0.1),
         blobLimits: (inner: 0.0, outer: 0.0), false),
        
        // MUTANT MOTH
        (numPoints: 24,
         n: 1,
         baseCurveRatio: 0.5,
         offsets: (in: -0.1, out: 0.4),
         axisRelOffsets: (inner: 0.1, outer: 0.1),
         blobLimits: (inner: 4, outer: 0.4), false)
    ]
            
    @ObservedObject var model = Model()
    @EnvironmentObject var layers : SuperEllipseLayers
    @EnvironmentObject var options : Options
    
    static let timerTimeIncrement : Double = 3.3
    static let animationTimeIncrement : Double = 3.0
    static let timerInitialTimeIncrement : Double = 0.0
    
    @State var showLayersList = true
    @State var showMoreOptionsList = false
    
    @State var timer: Timer.TimerPublisher
                            = Timer.publish(every: PageView.timerTimeIncrement,
                                            on: .main, in: .common)
    @State var isAnimating = false
    @State var isFirstTappedCycle = true
    
    var randomPermutations = true
        
    var pageType: PageType
    
    //MARK:-
    init(pageType: PageType, description: PageDescription, size: CGSize) {
        
        print("\nPageView.init(). pageType.\(pageType.rawValue))")
        print ("PageView.init(). screen size   = W: {\(size.width)}, H: {\(size.height)}")
        print ("PageView.init(). semiAxis size = W: {\((size.width/2.0).format(fspec: "4.2"))} H: {\((size.height/2.0).format(fspec: "4.2"))}")
        print ("PageView.init(). baseCurveRatio: {\((description.baseCurveRatio).format(fspec: "4.2"))}")

        self.pageType = pageType
        self.description = description

        var a = Double(size.width/2.0)
        var b = Double(size.height/2.0)
        
        print ( "PageView.init(). baseCurve.a: {\((a).format(fspec: "6.2"))}\n" +
                "               . baseCurve.b: {\((b).format(fspec: "6.2"))}")
        
        let minAorB = min(a, b)
        model.newStyleOffsets = (inner: CGFloat(minAorB) * description.axisRelOffsets.inner,
                                 outer: CGFloat(minAorB) * description.axisRelOffsets.outer)
        
//        print("PageView.init(). offsets = [NEW STYLE] (inner: \(offsets.inner.format(fspec: "6.2")), outer: \(offsets.outer.format(fspec: "6.2")))")
        
        a = a * description.baseCurveRatio
        b = b * description.baseCurveRatio

        print ( "PageView.init(). baseCurve.a: {\((a).format(fspec: "6.2"))}\n" +
                "               . baseCurve.b: {\((b).format(fspec: "6.2"))}")

        model.calculateSuperEllipseCurvesFamily(for: pageType,
                                                pageDescription: description,
                                                axes: (a: a, b: b)
        )
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
    //MARK:- DISPLAY THE FOLLOWING LAYERS IF FLAGGED

    // comparing gating for visibility here via layers.isVisible()
    // vs accessing the same info inside the invoked struct via @EnvironmentObject.
    // note we use @EnvironmentObject where smoothed/non-smoothed is involved.
            
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
        /*
            the view PageGradientBackground() will work in a .background(),
            but all the other remaining views in the PageView.body are
            conditioned, and if all are set to false, the PageView "crashes"
         
            .background(PageGradientBackground())
         */

        .onDisappear {
            
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
            withAnimation(Animation.easeOut(duration: PageView.animationTimeIncrement))
            {
                let doRandom = options.isSelected(optionWithType: .randomPerturbations)
                model.animateToNextZigZagPhase(doRandom: doRandom)
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
                    let s = CGSize(width: 244, height: 590)
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
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    let s = CGSize(width: 274, height: 300)
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
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
        
        var edgeOffset = CGSize(width: 1, height: 1)
        
        var body: some View {
            HStack {
                Spacer()
                
                LayersSelectionListButton(faceColor: .blue,
                                          edgeColor: .white,
                                          edgeOffset: edgeOffset)
                    .onTapGesture {
                        showLayersList.toggle()
                    }
                Spacer()
                
                MoreOptionsListButton(iconName: PencilSymbol.PENCIL_AND_ELLIPSIS,
                                      faceColor: .blue,
                                      edgeColor: .white,
                                      edgeOffset: edgeOffset)
                    .onTapGesture {
                        showMoreOptionsList.toggle()
                    }
                Spacer()
            }
            .scaleEffect(1.2)
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
