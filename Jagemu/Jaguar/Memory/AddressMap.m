//
//  AddressMap.m
//  Jagemu
//
//  Created by Kate on 7/14/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "AddressMap.h"

@implementation AddressMapEntry : NSObject

-(instancetype)initWithStart:(uint32_t)start end:(uint32_t)end
{
    self = [super init];
    
    self.start = start;
    self.end = end;
    
    return self;
}

@end

@implementation AddressMap

-(instancetype)init
{
    self = [super init];
    
    self.entries = [[NSArray alloc] init];
    
    return self;
}

@end
