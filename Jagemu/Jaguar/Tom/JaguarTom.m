//
//  JaguarTom.m
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarTom.h"
#import "JaguarSystem.h"
#import "JaguarTom+Render.h"

@implementation JaguarTom

@synthesize registers = _registers;
@synthesize objectProcessor = _objectProcessor;

const NSUInteger LBUF_bytesPerPixel = 4;
const NSUInteger LBUF_bytesPerRow = LBUF_bytesPerPixel * 320;

-(instancetype)init
{
    self = [super init];
    self.registers = malloc(sizeof(struct tom_registers_t));
    self.objectProcessor = [[JaguarObjectProcessor alloc] init:self.registers];
    self.registers->LBUF_ACTIVE = self.registers->LBUF_A;

    [self fillColorLookupTables];
    
    return self;
}

-(void)executeHalfLine
{
    // Do stuff!
    
    // - Run the object processor if required
    // - Run the RISC GPU for a half-frame if enabled
    
    const uint16_t halfline = _registers->VC;
    const uint16_t visible_halfline_start = _registers->VDB;
    const uint16_t visible_halfline_end = _registers->VDE;
    
    // Object processor only runs on even lines.
    if(halfline & 0x01)
        return; // odd half-line
    
    //printf("Tom half-line (VC %d, VP %d) |", halfline, _registers->VP);
    
    // Are we in the visible area?
    if(halfline >= visible_halfline_start && halfline <= visible_halfline_end)
    {
        // Find the current line buffer and fill it with the background color, if flag is set.
        uint16_t *current_line_buffer = (uint16_t *)_registers->LBUF_ACTIVE;
        for(int i=0; i < LINE_BUFFER_LONG_WIDTH; i++)
        {
            _registers->LBUF_ACTIVE[i] = 0x00000000;
        }
        
        if(_registers->VMODE & 0x80) // BGEN bit
        {
            // Grab the background color and fill.
            uint16_t bg_color = _registers->BG;
            for(int i=0; i<LINE_BUFFER_WORD_WIDTH; i++)
            {
                current_line_buffer[i] = bg_color;
            }
        }
        
        // Run the object processor for a half-line.
        [[self objectProcessor] executeHalfLine];
    }
    
    //printf("\n");
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

-(void)reset
{
    // Default value of MEMCON1.
    // ROM is in the upper 8MB
    // ROM is 8-bit
    // ROM access is 10 clock cycles
    // RAM is zero wait state
    // Peripherals are 4 cycles per access
    // CPU has a 16-bit data bus
    _registers->MEMCON1 = 0x1861;
    _registers->VMODE = 0x6C1;
    
    //DEBUG: Match the boot ROM's setup. The boot ROM won't execute yet.
    //https://www.mulle-kybernetik.com/jagdox/video.html#VIDEO for details
    
    _registers->VP = 523; // 525 lines
    _registers->VBB = 500;
    _registers->VBE = 24;
    _registers->VS = 517;
    _registers->VEB = 511;
    _registers->VEE = 6;
    
    // 240 visible scanlines
    _registers->VDB = 38;
    _registers->VDE = 518;
    
    _registers->HP = 1084;
    _registers->HS = 1741;
    _registers->HBE = 125;
    _registers->HBB = 1713;
    _registers->HVS = 651;
    _registers->HEQ = 782;
    
    _registers->HDB1 = 203;
    _registers->HDB2 = 203;
    _registers->HDE = 1665;
    
    // TEST
    //_registers->BG = 0xFFFF;
}

/*
 * Rendering functions
 */

// DEBUG: taken from Virtual Jaguar


/* Interrupts */
-(void)updateInterrupts
{
    //VBLANK interrupt
    if(_registers->VI == _registers->VC)
    {
        // C_VIDENA is bit 0
        _registers->INTERRUPTS_WAITING = _registers->INTERRUPTS_WAITING | 0x1;
    }
    
    if(_registers->INTERRUPTS_WAITING > 0)
    {
        m68k_set_irq(M68K_IRQ_2);
    }
    else
    {
        m68k_set_irq(M68K_IRQ_NONE);
    }
}

@end
