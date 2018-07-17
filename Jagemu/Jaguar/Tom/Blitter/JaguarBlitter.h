//
//  JaguarBlitter.h
//  Jagemu
//
//  Created by Kate on 7/14/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressMap.h"
#import "JaguarBlitterFlags.h"

struct blitter_registers_t;

enum blitter_state_t {
    BLITTER_WILL_ACTIVATE_AFTER_THIS_INSTRUCTION,       // In the middle of a CPU write operation to B_CMD. Blitter will activate during the next instruction callback.
    BLITTER_IS_ACTIVE,                                  // Blitter is performing an operation.
    BLITTER_IS_IDLE,                                    // Blitter is totally idle.
    BLITTER_COLLISION_DETECTION                         // Blitter is halted pending collision detection processing.
};

@interface JaguarBlitter : NSObject
{
    struct blitter_registers_t *_registers;
    enum blitter_state_t _current_state;
}

@property struct blitter_registers_t *registers;
@property struct blitter_registers_t *internal_state;
@property enum blitter_state_t current_status;
@property uint32_t cycles_remaining;
@property struct blitter_a1_flags_t a1_flags;
@property struct blitter_a2_flags_t a2_flags;

-(instancetype)init;

-(uint32_t)buildBCMDRead;
-(void)triggerBlitterActivation;
-(void)performBlit;
-(void)doInstantBlit;

@end
