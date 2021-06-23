//
//  SELayersVisibilityToggles.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-11.
//

import SwiftUI

struct SELayerGroupsVisibility: View {
    
    @ObservedObject var model: Model
    @EnvironmentObject var layers : SELayersViewModel
    
    var deviceSize: PlatformSpecifics.SizeClass

    var body: some View {

    // STATIC SUPPORT CURVES BACKDROP
        Group {
            if layers.isVisible(layerWithType: .normals) {
                NormalsPlusMarkers(normals: model.normalsCurve,
                                   markerCurves: model.boundingCurves,
                                   markerRadius: markerStyles[.offsets]!)
            }
            if layers.isVisible(layerWithType: .offsetsEnvelope) {
                OffsetCurves(curves: model.boundingCurves,
                             markerRadius: markerStyles[.offsets]!,
                             showOffsets: (inner: false, outer: true))
            }
        }
        
    // ANIMATING STROKE & FILL
        Group {
            if layers.isVisible(layerWithType: .blob_filled) {
                AnimatingBlob_Filled(curve: model.blobCurve,
                                     layerType: .blob_filled)
            }
            if layers.isVisible(layerWithType: .blob_stroked) {
                AnimatingBlob_Stroked(curve: model.blobCurve)
            }
        }

    // STATIC MID-LEVEL SUPPORT CURVES
        Group {
            if layers.isVisible(layerWithType: .baseCurve_and_markers) {
                BaseCurve_And_Markers(curve: model.baseCurve.map{ $0.vertex },
                                      markerRadius: markerStyles[.baseCurve]!)
            }
            if layers.isVisible(layerWithType: .offsetsEnvelope) {
                OffsetCurves(curves: model.boundingCurves,
                             markerRadius: markerStyles[.offsets]!,
                             showOffsets: (inner: true, outer: false))
            }
            
            if DEBUG.OVERLAY_SECOND_COPY_OF_NORMALS_PLUS_MARKERS {
                if layers.isVisible(layerWithType: .normals) {
                    NormalsPlusMarkers(normals: model.normalsCurve,
                                       markerCurves: model.boundingCurves,
                                       markerRadius: markerStyles[.offsets]!)
                }
            }
        }
        
    // FRONTMOST ANINMATING VERTEX MARKERS
        Group {
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
    }
}

struct SELayersVisibilityToggles_Previews: PreviewProvider {
    static var previews: some View {
        
        SELayerGroupsVisibility(model: Model(),
                                deviceSize: PlatformSpecifics.SizeClass.regular)
    }
}
