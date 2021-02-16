//
//  Layers.swift (BezierBlobs)
//  Created by Howard Katz on 2021-02-04.

import Combine

struct Layer {
    var type : LayerType
    var section: SectionType
    var visible = false
}

class Layers : ObservableObject {
      
    static let DEBUG_PRINT_LAYERS = false
    
    @Published var layers : [Layer] = [
        
        .init(type: .baseCurve, section: .staticSupportCurves,
              visible: true),
        .init(type: .baseCurve_markers, section: .staticSupportCurves,
              visible: true),
        .init(type: .normals, section: .staticSupportCurves),
        .init(type: .envelopeBounds, section: .staticSupportCurves),
        .init(type: .zigZags_with_markers, section: .staticSupportCurves),
    // -------------------------------------------------------------------
        .init(type: .blob_stroked, section: .animatingBlobCurves,
              visible: true),
        .init(type: .blob_filled, section: .animatingBlobCurves,
              visible: false),
        .init(type: .blob_markers, section: .animatingBlobCurves),
        .init(type: .blob_vertex_0_marker, section: .animatingBlobCurves,
              visible: true),
    // --------------------------------------------------=---------------
        .init(type: .showAll, section: .shortcuts),
        .init(type: .hideAll, section: .shortcuts)
    ]
    
    init() {
        if Layers.DEBUG_PRINT_LAYERS {
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
    case baseCurve = "base Curve"
    case baseCurve_markers = "base Curve markers"
    case normals = "normals"
    case envelopeBounds = "envelope Bounds"
    case zigZags_with_markers = "zig-zags (animated)"
    
    case blob_stroked = "stroked"
    case blob_filled = "filled"
    case blob_markers = "vertex markers"
    case blob_vertex_0_marker = "vertex[0] marker"
    
    case showAll = "show All layers"
    case hideAll = "hide All layers"
}

enum SectionType {
    case animatingBlobCurves
    case staticSupportCurves
    case shortcuts
}
