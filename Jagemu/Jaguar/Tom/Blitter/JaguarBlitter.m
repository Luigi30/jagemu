//
//  JaguarBlitter.m
//  Jagemu
//
//  Created by Kate on 7/14/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarBlitter.h"
#import "JaguarBlitter+Registers.h"

@implementation JaguarBlitter

@synthesize registers;

-(instancetype)init
{
    self = [super init];
    _registers = malloc(sizeof(struct blitter_registers_t));    
    return self;
}

@end
