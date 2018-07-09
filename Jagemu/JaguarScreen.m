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
    MTLTextureDescriptor *desc = [[MTLTextureDescriptor alloc] init];
    //desc.pixelFormat = MTLPixelFormatBGRA8Unorm;
    desc.pixelFormat = MTLPixelFormatRGBA8Uint;
    desc.width = 320;
    desc.height = 256;
    desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
    self.Texture = [device newTextureWithDescriptor:desc];
    
    return self;
}

@end
