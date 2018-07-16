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
@synthesize current_state;
@synthesize cycles_remaining;

bool blitter_will_activate = false;
bool blitter_is_active = false;

-(instancetype)init
{
    self = [super init];
    registers = malloc(sizeof(struct blitter_registers_t));
    current_state = BLITTER_IS_IDLE;
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
    if(current_state == BLITTER_IS_IDLE)
    {
        current_state = BLITTER_WILL_ACTIVATE_AFTER_THIS_INSTRUCTION;
    }
}

/*
-(void)performCycles:(uint32_t)cycles
{
    NSLog(@"BLITTER: Performing %d cycles...", cycles);
    
    while(cycles_remaining > 0)
    {
        cycles_remaining -= 1;
    }
}
 */

-(void)performBlit
{
    // TODO: totally inaccurate and not cycle accurate since, well, it's doing it all at once.
    // find whatever docs Virtual Jaguar used (which it claims are more accurate) and base it on them
    
    current_state = BLITTER_IS_ACTIVE;
    
    NSLog(@"BLITTER: Blit! (TODO: fill in the registers here)");
    
    current_state = BLITTER_IS_IDLE;
}

@end
