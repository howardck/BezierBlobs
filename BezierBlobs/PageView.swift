//
//  PageView.swift
//  TabViews
//
//  Created by Howard Katz on 2020-10-28.
//

import SwiftUI

struct PageView: View {

    static let animationStyle = Animation.easeOut(duration: AnimationTimer.animationTimeIncrement)
    
    // might be useful later for fixed perturbation ranges
    static let NIL_RANGE : Range<CGFloat>
                = 0..<CGFloat(SEParametrics.VANISHINGLY_SMALL_DOUBLE)
    
    let descriptors: PageDescriptors
    let pageType: PageDescriptors.PageType
    
    var numPoints : Int = 0
    
    //MARK:- @ObservedObject
    
    @ObservedObject var model = Model()
    @ObservedObject var animationTimer = AnimationTimer()
    
    //MARK:- @EnvironmentObject

    @EnvironmentObject var layers : SELayersViewModel
    @EnvironmentObject var options : MiscOptionsModel
    @EnvironmentObject var colorScheme : ColorScheme
    
    //MARK:- @State
    
    @State var showLayersList = false
    @State var showMiscOptionsList = false
    
    
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

        // do the same for relative perturbationDeltas -> absolute pDeltas
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
    
    var body: some View {
    
        ZStack {

            PageGradientBackground()
            
            // per-layer visibility turned on & off according to settings
            // in the layers view model, these in turn responding to
            // selections made by the user in the layers chooser.
            
            SELayerGroupsVisibility(model: self.model)
        }
        //MARK:- onAppear()
        .onAppear {
            print("\nPageView.onAppear{ PageType.\(pageType) }")
        }
        
        .onDisappear {
            animationTimer.cancel()
        }
    
        //MARK: onReceive()
        .onReceive(animationTimer.timer) { _ in
            
            withAnimation(PageView.animationStyle) {
                
                switch options.currPerturbStrategy {
                    
                    case .staticZigZags :
                        model.animateToNextFixedPerturbationDelta()
                        
                    case .randomizedZigZags :
                        model.animateToNextRandomizedPerturbationDelta()
                }
            }
            
            animationTimer.restart()
        }
        
        //MARK: onTapGesture(2)
        .onTapGesture(count: 2) {
            
            withAnimation(Animation.easeInOut(duration: 0.6))
            {
                animationTimer.cancel()
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
                if !animationTimer.isAnimating {
                    animationTimer.start()
                }
                else {
                    animationTimer.cancel()
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
