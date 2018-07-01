//
//  JaguarScreen.m
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarScreen.h"

@implementation JaguarScreen

@synthesize Texture = _texture;

-(instancetype)initWith:(id<MTLDevice>)device
{
    /*
    let texture_desc = MTLTextureDescriptor()
    texture_desc.pixelFormat = .bgra8Unorm
    texture_desc.width = 320
    texture_desc.height = 256
    texture_desc.usage = [.shaderRead, .renderTarget]
    back_buffer = device!.makeTexture(descriptor: texture_desc)
     */
    
    MTLTextureDescriptor *desc = [[MTLTextureDescriptor alloc] init];
    desc.pixelFormat = MTLPixelFormatBGRA8Unorm;
    desc.width = 320;
    desc.height = 256;
    desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
    self.Texture = [device newTextureWithDescriptor:desc];
    
    return self;
}

@end
