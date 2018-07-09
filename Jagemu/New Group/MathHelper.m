//
//  MathHelper.m
//  Jagemu
//
//  Created by Kate on 7/7/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "MathHelper.h"

@implementation MathHelper

+(UInt32)swapWordsOfLong:(UInt32)value
{
    return (value & 0xFFFF0000) >> 16 | (value & 0x0000FFFF) << 16;
}

@end
