//
//  JaguarBlitter+Calculations.m
//  Jagemu
//
//  Created by Kate on 7/16/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarBlitter+Calculations.h"
#import "JaguarBlitter+Registers.h"
#import "JaguarBlitterFlags.h"

@implementation JaguarBlitter (Calculations)

/*
enum WINDOW_WIDTH_TABLE {
    WID2 = 4,
    WID4 = 8,
    WID6 = 10,
    WID8 = 12,
    WID10 = 13,
    WID12 = 14,
    WID14 = 15,
    WID16 = 16,
    WID20 = 17,
    WID24 = 18,
    WID28 = 19,
    WID32 = 20,
    WID40 = 21,
    WID48 = 22,
    WID56 = 23,
    WID64 = 24,
    WID80 = 25,
    WID96 = 26,
    WID112 = 27,
    WID128 = 28,
    WID160 = 29,
    WID192 = 30,
    WID224 = 31,
    WID256 = 32,
    WID320 = 33,
    WID384 = 34,
    WID448 = 35,
    WID512 = 36,
    WID640 = 37,
    WID768 = 38,
    WID896 = 39,
    WID1024 = 40,
    WID1280 = 41,
    WID1536 = 42,
    WID1792 = 43,
    WID2048 = 44,
    WID2560 = 45,
    WID3072 = 46,
    WID3584 = 47,
};
 */

static uint32_t WINDOW_WIDTH_TABLE[] = {
    0,    0,    0,    0,                    // Note: This would really translate to 1, 1, 1, 1
    2,    0,    0,    0,
    4,    0,    6,    0,
    8,    10,   12,   14,
    16,   20,   24,   28,
    32,   40,   48,   56,
    64,   80,   96,  112,
    128,  160,  192,  224,
    256,  320,  384,  448,
    512,  640,  768,  896,
    1024, 1280, 1536, 1792,
    2048, 2560, 3072, 3584
};

-(uint32_t)getWindowWidth:(uint8_t)fp_value
{
    return WINDOW_WIDTH_TABLE[fp_value];
}

-(void)populateA1Flags:(struct blitter_a1_flags_t *)flags
{
    flags->window_width = [self getWindowWidth:(_registers->A1_FLAGS & 0x5E00) >> 9];
    flags->pitch = (_registers->A1_FLAGS & 0x03);
    flags->pixel_size = (_registers->A1_FLAGS & 0x38) >> 3;
    flags->z_offset = (_registers->A1_FLAGS & 0x1C8) >> 6;
    flags->x_add_ctrl = (_registers->A1_FLAGS = 0x30000) >> 16;
    flags->y_add_ctrl = (_registers->A1_FLAGS = 0x40000) >> 18;
    flags->x_sign_sub = (_registers->A1_FLAGS = 0x80000) >> 19;
    flags->y_sign_sub = (_registers->A1_FLAGS = 0x100000) >> 20;
}

@end
