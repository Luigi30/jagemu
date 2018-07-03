//
//  JaguarSystem.m
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarSystem.h"

#import "Jagemu-Swift.h"

@implementation JaguarSystem

@synthesize Memory = _Memory;
@synthesize Tom = _Tom;
@synthesize Screen = _Screen;
@synthesize Texture = _Texture;
@synthesize Timers = _Timers;

+ (id)sharedJaguar
{
    static JaguarSystem *sharedJaguarSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedJaguarSingleton = [[self alloc] init];
    });
    return sharedJaguarSingleton;
}

- (instancetype) init
{
    self = [super init];
    
    self.Memory = [[JaguarMemory alloc] init];
    self.Tom = [[JaguarTom alloc] init];
    self.Texture = [[JaguarScreen alloc] initWith:MTLCreateSystemDefaultDevice()];
    self.Timers = [[JaguarSyncTimers alloc] init];
    
    self->oddFrame = false;
    
    /* Add the half-line timer to the timers list */
    SyncTimer *timer = [[SyncTimer alloc] initWithMicroseconds:USEC_PER_HALFLINE
                                                     repeating:true
                                                    timer_type:T_TYPE_HALFLINE_END
                                                        source:T_DEV_INTERNAL
                                                   destination:T_DEV_INTERNAL
                                                      callback:@selector(CALLBACK_halfLine)];
    [[self Timers] addTimer:timer];
    
    return self;
}

- (void)runJagForCycles:(UInt32)cycles
{
    m68k_execute(cycles);
}

/* Execution functions. */


Boolean frame_is_complete;
- (void)performFrame
{
    /* Perform one frame of Jaguar.
     * For our purposes, one frame contains 262 scanlines, 240 of which are visible.
     * Thus, we have 320x240 output. */
    frame_is_complete = false;
    
    printf("One half-line is %f uS\n", USEC_PER_HALFLINE);
    
    do
    {
        double microseconds = [[self Timers] microsecondsToNextTimerExpiration];
        
        //printf("Next timer expires in %f microseconds\n", microseconds);
        //printf("Executing %f clocks\n", USEC_TO_M68K_CLOCKS(microseconds));
        
        m68k_execute(USEC_TO_M68K_CLOCKS(microseconds));
        
        [[self Timers] performNextTimer];
    }
    while (!frame_is_complete);
    
    printf("Frame complete\n");
      
    // Flip this bit each frame.
    oddFrame = ~oddFrame;
    
    return;
}

/* Callbacks */

// Called every time the system is starting a half-line.
-(void)CALLBACK_halfLine
{
    // Advance the vertical line counter and update it
    self.Tom.registers->VC += 1;
    
    // TODO: VI - video interrupt
    
    [[self Tom] executeHalfLine];
    
    if(self.Tom.registers->VC > self.Tom.registers->VP+1) // VP is actually VP+1
    {
        self.Tom.registers->VC = 0; // ? exact timing
        frame_is_complete = true;
    }
}

@end

/*************************************
 MUSASHI SUPPORT
 MUSASHI SUPPORT
 MUSASHI SUPPORT
 *************************************/

/* Musashi support. Here be C. */
int cpu_irq_ack(int level)
{
    return 0; // TODO
}

/* Reset callback. */
void cpu_pulse_reset(void)
{
    [[[JaguarSystem sharedJaguar] Tom] reset];
}

/* Called before each instruction, if configured so. */
void cpu_instr_callback(void)
{
    
}

uint8_t fc;
void cpu_set_fc(unsigned int fcv)
{
    fc = fcv;
}

/* Musashi memory functions */
/* CPU reads */
unsigned int cpu_read_byte(unsigned int address)
{
    if(address < 0x400000)
    {
        return [JaguarSystem.sharedJaguar Memory].WorkRAM[address & 0x1FFFFF];
    }
    else if(address >= 0x800000 && address < 0xE00000)
        return [JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000];
    else if(address >= 0xE00000 && address < 0xE20000)
        return [JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000];
    else return 0;
}

unsigned int cpu_read_word(unsigned int address)
{
    if(address < 0x400000)
        return ([JaguarSystem.sharedJaguar Memory].WorkRAM[address & 0x1FFFFF] << 8) | ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+1 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000] << 8) | ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+1]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000] << 8) | ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+1]);
    else return 0;
}

unsigned int cpu_read_long(unsigned int address)
{
    if(address < 0x400000)
        return ([JaguarSystem.sharedJaguar Memory].WorkRAM[address & 0x1FFFFF] << 24) |
        ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+1 & 0x1FFFFF] << 16) |
        ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+2 & 0x1FFFFF] << 8) |
        ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+3 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000] << 24) |
        ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+1] << 16) |
        ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+2] << 8) |
        ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+3]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000] << 24) |
        ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+1] << 16) |
        ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+2] << 8) |
        ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+3]);
    else return 0;
}

unsigned int cpu_read_word_dasm(unsigned int address)
{
    if(address < 0x400000)
        return ([JaguarSystem.sharedJaguar Memory].WorkRAM[address & 0x1FFFFF] << 8) | ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+1 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000] << 8) | ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+1]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000] << 8) | ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+1]);
    else return 0;
}

unsigned int cpu_read_long_dasm(unsigned int address)
{
    if(address < 0x400000)
        return ([JaguarSystem.sharedJaguar Memory].WorkRAM[address & 0x1FFFFF] << 24) |
        ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+1 & 0x1FFFFF] << 16) |
        ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+2 & 0x1FFFFF] << 8) |
        ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+3 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000] << 24) |
        ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+1] << 16) |
        ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+2] << 8) |
        ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+3]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000] << 24) |
        ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+1] << 16) |
        ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+2] << 8) |
        ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+3]);
    else return 0;
}

/* CPU writes */
void cpu_write_byte(unsigned int address, unsigned int value)
{
    if(address < 0x400000)
    {
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address & 0x1FFFFF] = value;
    }
    else if(address >= 0x800000 && address < 0xE00000)
        wrote_to_rom(address, value);
    else if(address >= 0xE00000 && address < 0xE20000)
        wrote_to_rom(address, value);
}

void cpu_write_word(unsigned int address, unsigned int value)
{
    if(address < 0x400000)
    {
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+0 & 0x1FFFFF] = (value & 0xFF00) >> 8;
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+1 & 0x1FFFFF] = (value & 0x00FF);
    }
    else if(address >= 0x800000 && address < 0xE00000)
        wrote_to_rom(address, value);
    else if(address >= 0xE00000 && address < 0xE20000)
        wrote_to_rom(address, value);
}

void cpu_write_long(unsigned int address, unsigned int value)
{
    if(address < 0x400000)
    {
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+0 & 0x1FFFFF] = (value & 0xFF000000) >> 24;
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+1 & 0x1FFFFF] = (value & 0x00FF0000) >> 16;
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+2 & 0x1FFFFF] = (value & 0x0000FF00) >> 8;
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+3 & 0x1FFFFF] = (value & 0x000000FF);
    }
    else if(address >= 0x800000 && address < 0xE00000)
        wrote_to_rom(address, value);
    else if(address >= 0xE00000 && address < 0xE20000)
        wrote_to_rom(address, value);
}
/*
 * To simulate real 68k behavior, first write the high word to
 * [address+2], and then write the low word to [address].
 */
void cpu_write_long_pd(unsigned int address, unsigned int value)
{
    if(address < 0x400000)
    {
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+0 & 0x1FFFFF] = (value & 0xFF000000) >> 24;
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+1 & 0x1FFFFF] = (value & 0x00FF0000) >> 16;
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+2 & 0x1FFFFF] = (value & 0x0000FF00) >> 8;
        [JaguarSystem.sharedJaguar Memory].WorkRAM[address+3 & 0x1FFFFF] = (value & 0x000000FF);
    }
    else if(address >= 0x800000 && address < 0xE00000)
        wrote_to_rom(address, value);
    else if(address >= 0xE00000 && address < 0xE20000)
        wrote_to_rom(address, value);
}

void wrote_to_rom(unsigned int address, unsigned int value)
{
    printf("Attempted write to ROM at %06X\n", address);
}

