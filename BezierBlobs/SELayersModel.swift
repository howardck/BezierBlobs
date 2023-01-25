//
//  SELayerGroupsViewModel.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-02-04.

import Combine

class SELayersModel : ObservableObject {
      
    static let DEBUG_PRINT_LAYERS = false
    
    static func loadDefaultLayers() -> [Layer] {
        [
        // ANIMATING BLOB CURVES
            // these animate various layers of the bezier blob animation(s).
            Layer(type: .animatingBlobFilled, section: .animatingCurves),
            Layer(type: .animatingBlobStroked, section: .animatingCurves, visible : true),
            Layer(type: .animatingBlobEvenMarkers, section: .animatingCurves, visible: true),
            Layer(type: .animatingBlobOddMarkers, section: .animatingCurves, visible: true),
            Layer(type: .animatingBlobOriginMarker, section: .animatingCurves, visible : true),
            
            // this animates the single orbital markers animation layer
            Layer(type: .animatingOrbitalMarkers, section: .animatingCurves),
            
        // STATIC SUPPORT CURVES
            Layer(type: .baseCurveWithMarkers, section: .staticSupportCurves, visible: true),
            Layer(type: .offsetCurves, section: .staticSupportCurves, visible: true),
            Layer(type: .normals, section: .staticSupportCurves, visible: true),
            
        // SHORTCUTS
            Layer(type: .showAll, section: .shortcuts),
            Layer(type: .hideAll, section: .shortcuts)
        ]
    }

    @Published var layers : [Layer] = loadDefaultLayers()
    
    init() {
        if SELayersModel.DEBUG_PRINT_LAYERS {
            print("initializing class Layers(): layers.count = {\(layers.count)}")
            for (ix, layer) in layers.enumerated() {
                print("layer[\(ix)] visible = {\(layer.visible)}")
        }}
    }
    
    func layerIsBlobAnimationLayer(layer: Layer) -> Bool {
        switch(layer.type) {
            case    .animatingBlobFilled, .animatingBlobStroked,
                    .animatingBlobOddMarkers, .animatingBlobEvenMarkers,
                    .animatingBlobOriginMarker :
                return true
            default :
                return false
        }
    }
    
    func anyBlobAnimationLayerIsVisible() -> Bool {
        for layer in self.layers {
            if layer.visible && layerIsBlobAnimationLayer(layer: layer) {
                return true
            }
        }
        return false
    }
    
    func isVisible(layerType: LayerType) -> Bool {
        layers.filter{ $0.type == layerType && $0.visible }.count == 1
    }
    
    func index(of layerType: LayerType) -> Int {
        layers.firstIndex( where: { $0.type == layerType } )!
    }
}

/*
    escaped unicode \u25be is black down-pointing small triangle
 */
enum LayerType : String {
    
    case animatingBlobStroked = "blob\u{25be}stroked"
    case animatingBlobFilled = "blob\u{25be}filled"
    case animatingBlobEvenMarkers = "blob\u{25be}even markers"
    case animatingBlobOddMarkers = "blob\u{25be}odd markers"
    case animatingBlobOriginMarker = "blob\u{25be}marker[0]"
    case animatingOrbitalMarkers = "orbitals\u{25be}all markers"
    
    case baseCurveWithMarkers = "basecurve"
    case offsetCurves = "inner & outer offsets"
    case normals = "normals"
    
    case showAll = "show all layers"
    case hideAll = "hide all layers"
}

struct Layer {
    var type : LayerType
    var section: SectionType
    var visible = false
}

enum SectionType {
    case animatingCurves
    case staticSupportCurves
    case shortcuts
}


