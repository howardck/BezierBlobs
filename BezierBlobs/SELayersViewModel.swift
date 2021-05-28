//
//  SELayerViewModel.swift (BezierBlobs)
//  Created by Howard Katz on 2021-02-04.

import Combine

class SELayersViewModel : ObservableObject {
      
    static let DEBUG_PRINT_LAYERS = false
    
    static let fillOnlyLayersModel : [Layer] = [
    
        .init(type: .blob_stroked, section: .animatingBlobCurves),
        .init(type: .blob_filled, section: .animatingBlobCurves,
              visible: true),
        .init(type: .blob_vertex_0_marker, section: .animatingBlobCurves,
              visible: true),
        .init(type: .blob_markers, section: .animatingBlobCurves,
              visible: false),
 
        // ----------------------------------------------------------------
        .init(type: .baseCurve, section: .staticSupportCurves,
              visible: false),
        .init(type: .baseCurve_markers, section: .staticSupportCurves,
              visible: false),
        .init(type: .offsetsEnvelope, section: .staticSupportCurves,
              visible: false),
        .init(type: .normals, section: .staticSupportCurves),

        // -----------------------------------------------------------------
        .init(type: .showAll, section: .shortcuts),
        .init(type: .hideAll, section: .shortcuts)
    ]

    
    @Published var layers : [Layer] = [
        
        .init(type: .blob_stroked, section: .animatingBlobCurves,
              visible: true),
        .init(type: .blob_filled, section: .animatingBlobCurves),
        .init(type: .blob_vertex_0_marker, section: .animatingBlobCurves,
              visible: true),
        .init(type: .blob_markers, section: .animatingBlobCurves,
              visible: true),

        // ----------------------------------------------------------------
        .init(type: .baseCurve, section: .staticSupportCurves,
              visible: true),
        .init(type: .baseCurve_markers, section: .staticSupportCurves,
              visible: true),
        .init(type: .offsetsEnvelope, section: .staticSupportCurves),
        .init(type: .normals, section: .staticSupportCurves),

        // -----------------------------------------------------------------
        .init(type: .showAll, section: .shortcuts),
        .init(type: .hideAll, section: .shortcuts)
    ]
    
    init() {
        layers = SELayersViewModel.fillOnlyLayersModel
        
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
    
    case blob_stroked = "stroked"
    case blob_filled = "filled"
    case blob_vertex_0_marker = "vertex[0]"
    case blob_markers = "all vertex markers"
    
    case baseCurve = "baseCurve"
    case baseCurve_markers = "basecurve markers"
    case offsetsEnvelope = "offsets"
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


