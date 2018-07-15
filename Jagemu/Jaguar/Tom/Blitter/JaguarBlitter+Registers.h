//
//  JaguarBlitter+Registers.h
//  Jagemu
//
//  Created by Kate on 7/14/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarBlitter.h"

// Blitter register block starts at $F02200.
struct blitter_registers_t {
    
    // Address registers - 32-bit
    uint32_t A1_BASE;   // $F02200
    uint32_t A1_FLAGS;  // $F02204
    uint32_t A1_CLIP;   // $F02208
    uint32_t A1_PIXEL;  // $F0220C
    uint32_t A1_STEP;   // $F02210
    uint32_t A1_FSTEP;  // $F02214
    uint32_t A1_FPIXEL; // $F02218
    uint32_t A1_INC;    // $F0221C
    uint32_t A1_FINC;   // $F02220
    
    uint32_t A2_BASE;   // $F02224
    uint32_t A2_FLAGS;  // $F02228
    uint32_t A2_MASK;   // $F0222C
    uint32_t A2_PIXEL;  // $F02230
    uint32_t A2_STEP;   // $F02234
    
    // Data registers - mostly 64-bit
    uint64_t B_SRCD;    // $F02240
    uint64_t B_DSTD;    // $F02248
    uint64_t B_DSTZ;    // $F02250
    uint64_t B_SRCZ1;   // $F02258
    uint64_t B_SRCZ2;   // $F02260
    uint64_t B_PATD;    // $F02268
    uint32_t B_IINC;    // $F02270
    uint32_t B_ZINC;    // $F02274
    uint32_t B_STOP;    // $F02278
    
    // B_I3-B_I0 and B_Z3-B_Z0 are not real registers.
};

@interface JaguarBlitter (Registers)

-(uint32_t)getRegisterAtOffset:(uint8_t)offset width:(int)width;
-(void)putRegisterAtOffset:(uint8_t)offset value:(uint64_t)value width:(int)width;

@end
