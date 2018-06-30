//
//  JaguarObjectProcessor.m
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarObjectProcessor.h"

@implementation JaguarObjectProcessor

-(instancetype)init:(struct tom_registers_t *)registers
{
    self = [super init];
    
    // Pointer to the Tom registers struct
    self.registers = registers;
    
    return self;
}

@end
