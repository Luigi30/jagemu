//
//  JaguarTom.m
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarTom.h"

@implementation JaguarTom

@synthesize registers = _registers;
@synthesize objectProcessor = _objectProcessor;

-(instancetype)init
{
    self = [super init];
    self.registers = malloc(sizeof(struct tom_registers_t));
    self.objectProcessor = [[JaguarObjectProcessor alloc] init:self.registers];
    
    self.registers->LBUF_ACTIVE = self.registers->LBUF_A;
    
    return self;
}

-(void) executeHalfLine:(int)halfline renderLine:(Boolean)renderLine
{
    // If we're in the visible area, this is the line number we're on. The OP will want to know this.
    int visibleAreaLine = halfline - 44;
    
    // Do stuff!
    
    // - Run the object processor if required
    // - Run the RISC GPU for a half-frame if enabled
    
}

-(UInt16)getVideoOverscanWidth
{
    // Page 5 of Technical Reference.pdf
    // Returns the number of pixels, including overscan, in one scanline.
    // The value is read from bits 9-11 of VMODE.
    
    int divisor = (self.registers->VMODE & 0x700);
    
    switch (divisor) {
        case 0x000:
            return 1330;
            break;
        case 0x100:
            return 665;
            break;
        case 0x200:
            return 443;
            break;
        case 0x300:
            return 332;
            break;
        case 0x400:
            return 266;
            break;
        case 0x500:
            return 222;
            break;
        case 0x600:
            return 190;
            break;
        case 0x700:
            return 166;
            break;
            
        default:
            return 0;
            break;
    }
}

@end
