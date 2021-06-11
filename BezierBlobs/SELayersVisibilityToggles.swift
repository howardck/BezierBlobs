//
//  SELayersVisibilityToggles.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-11.
//

import SwiftUI

struct SELayersVisibilityToggles: View {
    
    var model: Model
    
    @EnvironmentObject var layers : SELayersViewModel

    var body: some View {
        Text("SELayersVisibilityToggles!")
        
        if layers.isVisible(layerWithType: .blob_vertex_0_marker) {
            AnimatingBlob_VertexZeroMarker(animatingCurve: model.blobCurve,
                                           markerStyle: markerStyles[.vertexOrigin]!)
        }
    }
}

struct SELayersVisibilityToggles_Previews: PreviewProvider {
    static var previews: some View {
        
        SELayersVisibilityToggles(model: Model())
    }
}
