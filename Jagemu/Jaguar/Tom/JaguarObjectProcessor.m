//
//  JaguarObjectProcessor.m
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarObjectProcessor.h"
#import "JaguarTomRegisters.h"

@implementation JaguarObjectProcessor

-(instancetype)init:(struct tom_registers_t *)registers
{
    self = [super init];
    
    // Pointer to the Tom registers struct
    self.registers = registers;
    
    return self;
}

-(void)executeHalfLine;
{
    // Process the object list.
    
    JAGPTR object_list_head;
    uint16_t current_line = _registers->VC;
    
    // object list pointer is stored little-endian, swap it to big-endian
    object_list_head = ((_registers->OLP & 0xFFFF0000) >> 16) | ((_registers->OLP & 0x0000FFFF) << 16);
    
    printf("OP: Processing object list at $%06X for vertical line count %d\n", object_list_head, current_line);
    
}

@end
