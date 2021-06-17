//
//  SELayerViewModel.swift (BezierBlobs)
//  Created by Howard Katz on 2021-02-04.

import Combine

class SELayersViewModel : ObservableObject {
      
    static let DEBUG_PRINT_LAYERS = false
    static func loadDefaultLayers() -> [Layer] {
    [
    // ANIMATING BLOB CURVES
        Layer(type: .blob_stroked, section: .animatingBlobCurves),
        Layer(type: .blob_filled, section: .animatingBlobCurves, visible: true),
        Layer(type: .blob_vertex_0_marker, section: .animatingBlobCurves, visible: true),
        Layer(type: .blob_outer_markers, section: .animatingBlobCurves, visible: true),
        Layer(type: .blob_all_markers, section: .animatingBlobCurves),
        
    // SUPPORT CURVES
        Layer(type: .baseCurve_and_markers, section: .staticSupportCurves),
        Layer(type: .offsetsEnvelope, section: .staticSupportCurves, visible: true),
        Layer(type: .normals, section: .staticSupportCurves, visible: true),
        
    // SHORTCUTS
        Layer(type: .showAll, section: .shortcuts),
        Layer(type: .hideAll, section: .shortcuts)
    ]
    }
    
    @Published var layers : [Layer] = loadDefaultLayers()
    
    init() {
        if SELayersViewModel.DEBUG_PRINT_LAYERS {
            print("initializing class Layers(): layers.count = {\(layers.count)}")
            for (ix, layer) in layers.enumerated() {
                print("layer[\(ix)] visible = {\(layer.visible)}")
        }}
    }
    
    func isVisible(layerWithType: LayerType) -> Bool {
        layers.filter{ $0.type == layerWithType && $0.visible }.count == 1
    }
    
    func index(of layerWithType: LayerType) -> Int {
        layers.firstIndex( where: { $0.type == layerWithType } )!
    }
}

enum LayerType : String {
    
    case blob_stroked = "blob stroked"
    case blob_filled = "blob filled"
    case blob_vertex_0_marker = "vertex[0] marker"
    case blob_outer_markers = "outer vertex markers"
    case blob_all_markers = "all vertex markers"
    
//    case baseCurve = "baseCurve"
    case baseCurve_and_markers = "basecurve"
    case offsetsEnvelope = "inner & outer offsets"
    case normals = "normals"
    
    case showAll = "show All layers"
    case hideAll = "hide All layers"
}

struct Layer {
    var type : LayerType
    var section: SectionType
    var visible = false
}

enum SectionType {
    case animatingBlobCurves
    case staticSupportCurves
    case shortcuts
}


