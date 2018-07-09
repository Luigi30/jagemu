//
//  Shaders.metal
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 renderedCoordinate [[position]];
    float2 textureCoordinate;
} TextureMappingVertex;

vertex TextureMappingVertex mapTexture(unsigned int vertex_id [[ vertex_id ]]) {
    
    /* TODO: pass interlace flag from Tom to the texture coordinates */
    
    float4x4 renderedCoordinates = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ),      /// (x, y, depth, W)
                                            float4(  1.0, -1.0, 0.0, 1.0 ),
                                            float4( -1.0,  1.0, 0.0, 1.0 ),
                                            float4(  1.0,  1.0, 0.0, 1.0 ));
    
    float4x2 textureCoordinates = float4x2(float2( 0.0, 1.0 ), /// (x, y)
                                           float2( 1.0, 1.0 ),
                                           float2( 0.0, 0.0 ),
                                           float2( 1.0, 0.0 ));
    TextureMappingVertex outVertex;
    outVertex.renderedCoordinate = renderedCoordinates[vertex_id];
    outVertex.textureCoordinate = textureCoordinates[vertex_id];
    
    return outVertex;
}

/*
fragment half4 displayTexture(TextureMappingVertex mappingVertex [[ stage_in ]],
                              texture2d<float, access::sample> texture [[ texture(0) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    float4 color = texture.sample(s, mappingVertex.textureCoordinate);
    
    return half4(color);
}
*/

fragment half4 displayTexture(TextureMappingVertex mappingVertex [[ stage_in ]],
//                              texture2d<float, access::sample> texture [[ texture(0) ]]) {
                              texture2d<uint, access::sample> texture [[ texture(0) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    //float4 color = texture.sample(s, mappingVertex.textureCoordinate);
    uint4 color = texture.sample(s, mappingVertex.textureCoordinate);
    
    return half4(float4( color.r * (1/255.0), color.g * (1 / 255.0), color.b * (1 / 255.0), 1.0) );
}

