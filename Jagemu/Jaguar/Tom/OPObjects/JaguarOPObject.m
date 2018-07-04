//
//  JaguarOPObject.m
//  Jagemu
//
//  Created by Kate on 7/3/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarOPObject.h"

@implementation JaguarOPObject
-(instancetype)initWith:(uint64_t)phrase
{
    self = [super init];
    
    return self;
}
@end

/***/

@implementation JaguarOPObjectBitmap
-(instancetype)initWith:(uint64_t)phrase1 second:(uint64_t)phrase2
{
    self = [super init];
    
    self.object_type = JAGOP_BITMAP;
    
    self.ypos       = (phrase1 >> 3) & 0x7FF;
    self.height     = (phrase1 >> 14) & 0x3FF;
    self.link       = (phrase1 >> 24) & 0x7FFFF;
    self.data       = (phrase1 >> 43) & 0x1FFFFF;
    
    self.xpos       = phrase2 & 0x7FF;
    self.depth      = (phrase2 >> 12) & 0x7;
    self.pitch      = (phrase2 >> 15) & 0x7;
    self.dwidth     = (phrase2 >> 18) & 0x3FF;
    self.iwidth     = (phrase2 >> 28) & 0x3FF;
    self.index      = (phrase2 >> 38) & 0x7F;
    self.reflect    = (phrase2 >> 45) & 1;
    self.rmw        = (phrase2 >> 46) & 1;
    self.trans      = (phrase2 >> 47) & 1;
    self.release_bus= (phrase2 >> 48) & 1;
    self.firstpix   = (phrase2 >> 49) & 0x3F;
    
    return self;
}
@end

/***/

@implementation JaguarOPObjectScaled
-(instancetype)initWith:(uint64_t)phrase1 second:(uint64_t)phrase2 third:(uint64_t)phrase3
{
    // Phrases 1 and 2 are the same as BITMAP, other than...
    self = [super initWith:phrase1 second:phrase2];
    
    // ...the object type
    self.object_type = JAGOP_SCALED;
    
    self.hscale = phrase3 & 0xFF;
    self.vscale = (phrase3 >> 8) & 0xFF;
    self.remainder = (phrase3 >> 16) & 0xFF;    
    
    return self;
}
@end

/***/

@implementation JaguarOPObjectGPU
-(instancetype)initWith:(uint64_t)phrase
{
    self = [super init];
    
    self.object_type = JAGOP_GPU;
    self.data = (phrase >> 3);
    
    return self;
}
@end

/***/

@implementation JaguarOPObjectBranch

-(instancetype)initWith:(uint64_t)phrase
{
    self = [super init];
    
    self.object_type = JAGOP_BRANCH;
    self.ypos = (phrase >> 3) & 0x7FF; // bits 3-13 of phrase
    self.cc = (phrase >> 14) & 0x7;
    self.link = (phrase >> 24) & 0x7FFFF;
    
    return self;
}

@end

/***/

@implementation JaguarOPObjectStop

-(instancetype)initWith:(uint64_t)phrase
{
    self = [super init];
    
    self.object_type = JAGOP_BITMAP;
    self.data = phrase >> 4;
    
    return self;
}

@end

/***/
