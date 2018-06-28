//
//  JaguarSystem.m
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarSystem.h"

@implementation JaguarSystem

@synthesize Memory = _Memory;
@synthesize Tom = _Tom;

- (instancetype) init
{
    self = [super init];
    
    self.Memory = [JaguarMemory alloc];
    self.Memory = [self.Memory init];
    
    return self;
}

@end
