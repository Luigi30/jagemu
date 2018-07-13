//
//  JaguarSystem.m
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarSystem.h"
#import "Jagemu-Swift.h"

Boolean debug_break;  // Ugly but C and Obj-C both need to see this.
JaguarSystem *sharedJaguar; // For C to avoid a bunch of dereferences every instruction.

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
    
    sharedJaguar = self;
    
    return self;
}

- (void)runJagForCycles:(UInt32)cycles
{
    m68k_execute(cycles);
}

/* Execution functions. */
-(Boolean)getDebugState
{
    return debug_break;
}

-(void)enableDebug
{
    debug_break = true;
}
-(void)disableDebug
{
    debug_break = false;
}

Boolean frame_is_complete;
- (void)performFrame
{
    /* Perform one frame of Jaguar.
     * For our purposes, one frame contains 262 scanlines, 240 of which are visible.
     * Thus, we have 320x240 output. */
    frame_is_complete = false;
    
    printf("One half-line is %f uS\n", USEC_PER_HALFLINE);
    printf("Executing frame from CPU PC %06X\n", m68k_get_reg(nil, M68K_REG_PC));
    
    do
    {
        double microseconds = [[self Timers] microsecondsToNextTimerExpiration];
        
        //printf("Next timer expires in %f microseconds\n", microseconds);
        //printf("Executing %f clocks\n", USEC_TO_M68K_CLOCKS(microseconds));
        
        m68k_execute(USEC_TO_M68K_CLOCKS(microseconds));
        
        if(!debug_break) // Don't update the screen if we are debugging.
            [[self Timers] performNextTimer];
    }
    while (!frame_is_complete && !debug_break);
    
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
    // The only IRQ line hooked up is IRQ 2, connecting TOM's interrupt out pin to the CPU.
    if(level == 2)
    {
        return 64; // TODO
    }
    else
    {
        printf("Illegal IRQ line asserted: %d", level);
        return 0x0;
    }
}

/* Reset callback. */
void cpu_pulse_reset(void)
{
    [[sharedJaguar Tom] reset];
    
    // OP debugging. Swap endianness of OLP.
    //[[[JaguarSystem sharedJaguar] Tom] registers]->OLP = (0x1DC0 << 16) | 0x0002;
}

/* Called before each instruction, if configured so. */
void cpu_instr_callback(void)
{
    if(debug_break == true)
    {
        m68k_modify_timeslice(0); // end this timeslice immediately
    }
    
    // If VI == VC, set the IRQ bit in INT1 and assert IRQ2.
    [[sharedJaguar Tom] updateInterrupts];
}

uint8_t fc;
void cpu_set_fc(unsigned int fcv)
{
    fc = fcv;
}

// TODO: turn the memory functions into an address map list and generate it automatically?

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

    else
    {
        unmapped_read_notify(address);
        return 0;
    }
}

unsigned int cpu_read_word(unsigned int address)
{
    if(address < 0x400000)
        return ([JaguarSystem.sharedJaguar Memory].WorkRAM[address & 0x1FFFFF] << 8) | ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+1 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000] << 8) | ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+1]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000] << 8) | ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+1]);
    
    /* TOM */
    else if(address >= 0xF00000 && address < 0xF00100)
        return ([[JaguarSystem.sharedJaguar Tom] getRegisterWordByOffset:(address - 0xF00000)]);
    else if(address >= 0xF00400 && address < 0xF00800)
        return ([[JaguarSystem.sharedJaguar Tom] getClutWordByOffset:(address - 0xF00000)]);
    
    else
    {
        unmapped_read_notify(address);
        return 0;
    }
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
    
    // TODO: long TOM reads
    
    else
    {
        unmapped_read_notify(address);
        return 0;
    }
}

unsigned int cpu_read_word_dasm(unsigned int address)
{
    if(address < 0x400000)
        return ([JaguarSystem.sharedJaguar Memory].WorkRAM[address & 0x1FFFFF] << 8) | ([JaguarSystem.sharedJaguar Memory].WorkRAM[address+1 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000] << 8) | ([JaguarSystem.sharedJaguar Memory].CartROM[address - 0x800000+1]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000] << 8) | ([JaguarSystem.sharedJaguar Memory].BootROM[address - 0xE00000+1]);
    
    /* TOM */
    else if(address >= 0xF00000 && address < 0xF00100)
        return ([[JaguarSystem.sharedJaguar Tom] getRegisterWordByOffset:(address - 0xF00000)]);
    else if(address >= 0xF00400 && address < 0xF00800)
        return ([[JaguarSystem.sharedJaguar Tom] getClutWordByOffset:(address - 0xF00000)]);
    else
    {
        unmapped_read_notify(address);
        return 0;
    }
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
    else
    {
        unmapped_read_notify(address);
        return 0;
    }
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
    
    /* TOM */
    else if(address >= 0xF00000 && address < 0xF00100)
        [[JaguarSystem.sharedJaguar Tom] putRegisterAtOffset:(address - 0xF00000) value:(value & 0xFF)];
    else if(address >= 0xF00400 && address < 0xF00800)
        [[JaguarSystem.sharedJaguar Tom] putClutByteByOffset:(address - 0xF00400) value:(value & 0xFF)];
    
    else
        unmapped_write_notify(address, value);
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
    
    /* TOM */
    else if(address >= 0xF00000 && address < 0xF00100)
        [[JaguarSystem.sharedJaguar Tom] putRegisterAtOffset:(address - 0xF00000) value:(value & 0xFFFF)];
    else if(address >= 0xF00400 && address < 0xF00800)
        [[JaguarSystem.sharedJaguar Tom] putClutWordByOffset:(address - 0xF00400) value:(value & 0xFFFF)];
    
    else
        unmapped_write_notify(address, value);
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
    
    /* TOM */
    else if(address >= 0xF00000 && address < 0xF00100)
        [[JaguarSystem.sharedJaguar Tom] putRegisterAtOffset:(address - 0xF00000) value:(value)];
    else if(address >= 0xF00400 && address < 0xF00800)
        [[JaguarSystem.sharedJaguar Tom] putClutLongByOffset:(address - 0xF00400) value:(value)];
    
    else
        unmapped_write_notify(address, value);
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
    
    /* TODO: TOM */
    else if(address <= 0xF00000 && address < 0xF00100)
        [[JaguarSystem.sharedJaguar Tom] putRegisterAtOffset:(address - 0xF00000) value:(value)];
    
    else
        unmapped_write_notify(address, value);
}

void wrote_to_rom(unsigned int address, unsigned int value)
{
    printf("Attempted write to ROM at %06X\n", address);
}

void unmapped_read_notify(unsigned int address)
{
    printf("Unmapped read from %06X: %0X\n", address);
}


void unmapped_write_notify(unsigned int address, unsigned int value)
{
    printf("Unmapped write to %06X: %0X\n", address, value);
}



