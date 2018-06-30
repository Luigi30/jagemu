//
//  JaguarScreenView.swift
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

import Cocoa
import Metal
import MetalKit

class JaguarScreenView: MTKView {
    
    var back_buffer: MTLTexture! = nil
    var library: MTLLibrary! = nil
    var renderPipelineState: MTLRenderPipelineState! = nil
    
    init(w: Int, h: Int)
    {
        super.init(frame: CGRect(x: 0, y: 0, width: w, height: h), device: MTLCreateSystemDefaultDevice())
        
        library = device!.makeDefaultLibrary()!
        
        let back_buffer_desc = MTLTextureDescriptor()
        back_buffer_desc.pixelFormat = .rgba8Uint // Jaguar outputs RGB888 so just match that
        
        // Simulate a 320x256 TV screen
        back_buffer_desc.width = 320
        back_buffer_desc.height = 256
        
        back_buffer = device!.makeTexture(descriptor: back_buffer_desc)
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.sampleCount = 1
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .invalid
        
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "mapTexture")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "displayTexture")
        
        do {
            try renderPipelineState = device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch {
            assertionFailure("Failed creating a render state pipeline. Can't render the texture without one.")
            return
        }

    }
    
    required convenience init(coder aDecoder: NSCoder)
    {
        self.init(w: 320, h: 256)
    }
    
    override func draw(_ dirtyRect: CGRect)
    {
        if let drawable = currentDrawable {
            if let pass_descriptor = currentRenderPassDescriptor {
                pass_descriptor.colorAttachments[0].texture = drawable.texture
                pass_descriptor.colorAttachments[0].storeAction = .store
                pass_descriptor.colorAttachments[0].loadAction = .clear
                pass_descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
                
                // Next, we create the command buffer, queue, and encoder. These objects together
                // encapsulate the actual submission of graphics commands to the GPU.
                let command_queue = device!.makeCommandQueue()
                let command_buffer = command_queue!.makeCommandBuffer()
                let encoder = command_buffer!.makeRenderCommandEncoder(descriptor: pass_descriptor)
                
                encoder?.setRenderPipelineState(renderPipelineState)
                encoder?.setFragmentTexture(currentDrawable?.texture, index: 0)
                encoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
                encoder?.endEncoding()
                
                command_buffer?.present(drawable)
                command_buffer?.commit()
            }
        }
    }
}
