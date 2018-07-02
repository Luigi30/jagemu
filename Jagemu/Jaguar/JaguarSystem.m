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
    
    return self;
}

- (void)runJagForCycles:(UInt32)cycles
{
    m68k_execute(cycles);
}

/* Execution functions. */
const NSUInteger bytesPerPixel = 4;
const NSUInteger bytesPerRow = bytesPerPixel * 320;

Boolean frame_is_complete;
- (void)performFrame
{
    /* Perform one frame of Jaguar.
     * For our purposes, one frame contains 262 scanlines, 240 of which are visible.
     * Thus, we have 320x240 output. */
    frame_is_complete = false;
    
    SyncTimer *timer = [[SyncTimer alloc] initWithMicroseconds:USEC_PER_HALFLINE
                                                     repeating:true
                                                    timer_type:T_TYPE_HALFLINE_END
                                                        source:T_DEV_INTERNAL
                                                   destination:T_DEV_INTERNAL
                                                      callback:@selector(CALLBACK_halfLine)];
    [[self Timers] addTimer:timer];
    
    do
    {
        double microseconds = [[self Timers] microsecondsToNextTimerExpiration];
        m68k_execute(USEC_TO_M68K_CLOCKS(microseconds));
        
        [[self Timers] performNextTimer];
    }
    while (!frame_is_complete);
    
    printf("Frame complete\n");
    
    //printf("performFrame\n");
    //printf("One half-line is %f uS\n", USEC_PER_HALFLINE);
    
    //printf("Executing %f clocks\n", timer.uS_to_fire * CPU_CLOCKS_PER_USEC);
    
    // Flip this bit each frame.
    oddFrame = ~oddFrame;
    
    return;
}

/* Callbacks */

-(void)CALLBACK_halfLine
{
    //printf("CALLBACK: Execute a half-line.\n");
    /*
     m68k_execute(CPU_CLOCKS_PER_HALFLINE);
     [[self Tom] executeHalfLine:lineNum renderLine:isRendering];
     
     uint32_t *active_line_buffer = [[JaguarSystem sharedJaguar] Tom].registers->LBUF_ACTIVE;
     if(isRendering)
     {
     MTLRegion region = MTLRegionMake2D(0, lineNum, 320, 1);
     [_Texture.Texture replaceRegion:region mipmapLevel:0 withBytes:active_line_buffer bytesPerRow:bytesPerRow];
     }
     */
    
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
    // set up MEMCON1 and MEMCON2
    
    // Default value of MEMCON1.
    // ROM is in the upper 8MB
    // ROM is 8-bit
    // ROM access is 10 clock cycles
    // RAM is zero wait state
    // Peripherals are 4 cycles per access
    // CPU has a 16-bit data bus
    [JaguarSystem.sharedJaguar Tom]->_registers->MEMCON1 = 0x1861;
    [JaguarSystem.sharedJaguar Tom]->_registers->VMODE = 0x6C1;
    
    //DEBUG: Match the boot ROM's setup. The boot ROM won't execute yet.
    //https://www.mulle-kybernetik.com/jagdox/video.html#VIDEO for details
    
    [JaguarSystem.sharedJaguar Tom]->_registers->VP = 523; // 525 lines
    [JaguarSystem.sharedJaguar Tom]->_registers->VBB = 500;
    [JaguarSystem.sharedJaguar Tom]->_registers->VBE = 24;
    [JaguarSystem.sharedJaguar Tom]->_registers->VS = 517;
    [JaguarSystem.sharedJaguar Tom]->_registers->VEB = 511;
    [JaguarSystem.sharedJaguar Tom]->_registers->VEE = 6;
    
    // 240 visible scanlines
    [JaguarSystem.sharedJaguar Tom]->_registers->VDB = 38;
    [JaguarSystem.sharedJaguar Tom]->_registers->VDE = 518;

    [JaguarSystem.sharedJaguar Tom]->_registers->HP = 1084;
    [JaguarSystem.sharedJaguar Tom]->_registers->HS = 1741;
    [JaguarSystem.sharedJaguar Tom]->_registers->HBE = 125;
    [JaguarSystem.sharedJaguar Tom]->_registers->HBB = 1713;
    [JaguarSystem.sharedJaguar Tom]->_registers->HVS = 651;
    [JaguarSystem.sharedJaguar Tom]->_registers->HEQ = 782;
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

