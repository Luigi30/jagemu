//
//  JaguarSystem.h
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

/* The Jaguar contains a CPU and two ASICs, Tom and Jerry.
 *
 * Tom contains the object processor, blitter, video generator, and GPU.
 * Jerry contains the I/O subsystem, sound subsystem, and DSP.
 *
 */

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#import "JaguarDefines.h"
#import "JaguarMemory.h"
#import "Tom/JaguarTom.h"
#import "JaguarScreen.h"

#import "m68k.h"

@class JaguarScreenView;

@interface JaguarSystem : NSObject {
    JaguarMemory *_Memory;
    JaguarTom *_Tom;
    JaguarScreenView *_Screen;
    JaguarScreen *_Texture;
    
    Boolean oddFrame;
}

@property JaguarTom *Tom;
@property JaguarMemory *Memory;
@property JaguarScreenView *Screen;
@property JaguarScreen *Texture;

+ (id)sharedJaguar;

- (instancetype) init;

- (void)runJagForCycles:(UInt32)cycles;

// Execution methods.
- (void)performFrame;
- (void)performHalfLine: (int)lineNum isRendering:(Boolean)isRendering;

@end

/* Musashi support */
extern uint8_t fc;

extern void cpu_set_fc(unsigned int fcv);

extern int cpu_irq_ack(int level);
extern void cpu_pulse_reset(void);
void cpu_instr_callback(void);

/* Musashi memory functions */
extern unsigned int cpu_read_byte(unsigned int address);
extern unsigned int cpu_read_word(unsigned int address);
extern unsigned int cpu_read_long(unsigned int address);
extern unsigned int cpu_read_word_dasm(unsigned int address);
extern unsigned int cpu_read_long_dasm(unsigned int address);
extern void cpu_write_byte(unsigned int address, unsigned int value);
extern void cpu_write_word(unsigned int address, unsigned int value);
extern void cpu_write_long(unsigned int address, unsigned int value);
extern void cpu_write_long_pd(unsigned int address, unsigned int value);

// Debug: Wrote to ROM.
void wrote_to_rom(unsigned int address, unsigned int value);
