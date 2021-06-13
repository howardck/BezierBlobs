//
//  SELayersVisibilityToggles.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-11.
//

import SwiftUI

struct SELayersVisibilityOnOff: View {
    
    @ObservedObject var model: Model
    @EnvironmentObject var layers : SELayersViewModel

    var body: some View {
        Text("OVERLAY!").font(.title).fontWeight(.heavy).foregroundColor(.blue)
        
        // ----------------------------------------------------------

        Group { // STATIC BACKDROP
            
            if layers.isVisible(layerWithType: .normals) {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   markerRadius: markerStyles[.offsets]!)
            }
            if layers.isVisible(layerWithType: .offsetsEnvelope) {
                OffsetsEnvelope(curves: model.boundingCurves,
                                markerRadius: markerStyles[.offsets]!,
                                showInnerOffset: false,
                                showOuterOffset: true)
            }
        }
        
        // ----------------------------------------------------------
        
        Group { // ANIMATING STROKE & FILL
            
            if layers.isVisible(layerWithType: .blob_filled) {
                AnimatingBlob_Filled(curve: model.blobCurve,
                                     layerType: .blob_filled)
            }
            if layers.isVisible(layerWithType: .blob_stroked) {
                AnimatingBlob_Stroked(curve: model.blobCurve)
            }
        }
        // ----------------------------------------------------------

        Group {  // STATIC MID-LEVEL LAYERS}
            if layers.isVisible(layerWithType: .baseCurve_and_markers) {
                BaseCurve_And_Markers(curve: model.baseCurve.map{ $0.vertex },
                                      markerRadius: markerStyles[.baseCurve]!)
            }
            if layers.isVisible(layerWithType: .offsetsEnvelope) {
                OffsetsEnvelope(curves: model.boundingCurves,
                                markerRadius: markerStyles[.offsets]!,
                                showInnerOffset: true,
                                showOuterOffset: false)
            }
            if Model.DEBUG_OVERLAY_SECOND_COPY_OF_NORMALS_PLUS_MARKERS {
                if layers.isVisible(layerWithType: .normals) {
                    NormalsPlusMarkers(normals: model.normalsCurve,
                                       markerCurves: model.boundingCurves,
                                       markerRadius: markerStyles[.offsets]!)
                }
            }
        }
        
        // ----------------------------------------------------------
        Group { // FRONTMOST ANINMATING VERTEX MARKERS
            
            if layers.isVisible(layerWithType: .blob_all_markers) {
                AnimatingBlob_Markers(curve: model.blobCurve,
                                      markerRadius: markerStyles[.blobAllMarkers]!)
            }
            if layers.isVisible(layerWithType: .blob_outer_markers) {
                AnimatingBlob_EvenNumberedVertexMarkers(curve: model.blobCurve,
                                                        vertices: model.evenNumberedVertices(
                                                            for: model.blobCurve),
                                                        markerRadius: markerStyles[.blobAllMarkers]!)
            }
            if layers.isVisible(layerWithType: .blob_vertex_0_marker) {
                AnimatingBlob_VertexZeroMarker(animatingCurve: model.blobCurve,
                                               markerRadius: markerStyles[.vertexOrigin]!)
            }
        }
        // ----------------------------------------------------------

    }
}

struct SELayersVisibilityToggles_Previews: PreviewProvider {
    static var previews: some View {
        
        SELayersVisibilityOnOff(model: Model())
    }
}
