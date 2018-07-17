//
//  JaguarBlitter.m
//  Jagemu
//
//  Created by Kate on 7/14/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarBlitter.h"
#import "JaguarBlitter+Registers.h"
#import "JaguarBlitter+Calculations.h"

@implementation JaguarBlitter

@synthesize registers;
@synthesize current_status;
@synthesize cycles_remaining;

bool blitter_will_activate = false;
bool blitter_is_active = false;

bool blitter_instant = true;

-(instancetype)init
{
    self = [super init];
    _registers = malloc(sizeof(struct blitter_registers_t));
    _internal_state = malloc(sizeof(struct blitter_registers_t));
    current_status = BLITTER_IS_IDLE;
    return self;
}

-(uint32_t)buildBCMDRead
{
    // Build a B_CMD read response.
    uint32_t response = 0;
    
    response |= (!blitter_is_active); // bit 0: blitter status. 0 = active, 1 = idle
    // bit 1: blitter is in collision detection mode. not emulated yet
    // bits 2-31 are diagnostic and undocumented
    
    return response;
}

-(void)triggerBlitterActivation
{
    NSLog(@"Blitter B_CMD written; Blitter will activate on next cycle.");
    if(current_status == BLITTER_IS_IDLE)
    {
        current_status = BLITTER_WILL_ACTIVATE_AFTER_THIS_INSTRUCTION;
    }
}

-(void)performBlit
{
    // TODO: totally inaccurate and not cycle accurate since, well, it's doing it all at once.
    // find whatever docs Virtual Jaguar used (which it claims are more accurate) and base it on them
    
    current_status = BLITTER_IS_ACTIVE;
    
    NSLog(@"BLITTER: Blit! B_CMD: $%08X\n A1_BASE: $%06X A2_BASE: $%06X\n A1_FLAGS: $%08X",
          _registers->B_CMD,
          _registers->A1_BASE,
          _registers->A2_BASE,
          _registers->A1_FLAGS);
    
    // TODO: more registers
    if(!blitter_instant)
    {
        
    }
    else
    {
        [self doInstantBlit];
    }
    
    current_status = BLITTER_IS_IDLE;
}

/***/

-(void)doInstantBlit
{
    // The blitter treats addresses as in a rectangular window. A window has a width and height in pixels.
    // The X pointer is an unsigned 16-bit value.
    // The Y pointer is an unsigned 12-bit value.
    
    // Fill in the A1 parameters.
    [self populateA1Flags:&_a1_flags];
    
    // 16-bit unsigned
    uint16_t a1_clip_width = _registers->A1_CLIP & 0x7FFF;
    uint16_t a1_clip_height = (_registers->A1_CLIP & 0x7FFF0000) >> 16;
    
    // 16-bit umsigned
    uint16_t a1_pixel_x = _registers->A1_PIXEL & 0x7FFF;
    uint16_t a1_pixel_y = (_registers->A1_PIXEL & 0x7FFF0000) >> 16;
    
    // 16-bit signed
    int16_t a1_step_x = _registers->A1_STEP & 0xFFFF;
    int16_t a1_step_y = (_registers->A1_STEP & 0xFFFF0000) >> 16;
    
    // 16-bit unsigned
    uint16_t a1_fraction_step_x = _registers->A1_FSTEP & 0xFFFF;
    uint16_t a1_fraction_step_y = (_registers->A1_FSTEP & 0xFFFF0000) >> 16;
    
    // 16-bit signed
    int16_t a1_increment_x = _registers->A1_INC & 0xFFFF;
    int16_t a1_increment_y = (_registers->A1_INC & 0xFFFF0000) >> 16;
    
    // 16-bit unsigned
    uint16_t a1_fraction_increment_x = _registers->A1_FINC & 0xFFFF;
    uint16_t a1_fraction_increment_y = (_registers->A1_FINC & 0xFFFF0000) >> 16;
    
    // Fill in the A2 parameters.
    [self populateA2Flags:&_a2_flags];
    
    // 16-bit unsigned
    uint16_t a2_pixel_x = _registers->A2_PIXEL & 0x7FFF;
    uint16_t a2_pixel_y = (_registers->A2_PIXEL & 0x7FFF0000) >> 16;
    
    // 16-bit signed
    int16_t a2_step_x = _registers->A2_STEP & 0xFFFF;
    int16_t a2_step_y = (_registers->A2_STEP & 0xFFFF0000) >> 16;
    
    // state machine parameters
    uint16_t inner_loop_iterations = (_registers->B_COUNT & 0x0000FFFF);
    uint16_t outer_loop_iterations = (_registers->B_COUNT & 0xFFFF0000) >> 16;
    
    uint32_t aligned_a1_base = _registers->A1_BASE & 0xFFFFFFF8;
    uint32_t aligned_a2_base = _registers->A2_BASE & 0xFFFFFFF8;
    
    NSLog(@"Blit size is %d x %d loop iterations", inner_loop_iterations, outer_loop_iterations);
    NSLog(@"Blit is $%06X -> $%06X", aligned_a1_base, aligned_a2_base);
    
    for(int outer_loops=0; outer_loops<outer_loop_iterations; outer_loops++)
    {
        //Perform a blitter outer loop
        
        for(int inner_loops=0; inner_loops<inner_loop_iterations; inner_loops++)
        {
            // Perform a blitter inner loop
        }
    }
    
}

@end
