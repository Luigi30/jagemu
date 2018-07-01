//
//  JaguarScreen.h
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface JaguarScreen : NSObject
{
    id<MTLTexture> _texture;
}

@property id<MTLTexture> Texture;

-(instancetype)initWith:(id<MTLDevice>)device;


@end
