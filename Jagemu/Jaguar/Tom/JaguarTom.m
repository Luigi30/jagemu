//
//  JaguarTom.m
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarTom.h"
#import "JaguarSystem.h"

#include "cry2rgb.h"

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

// Color conversion tables from VJ 2.1
uint32_t RGB16ToRGB32[0x10000];
uint32_t CRY16ToRGB32[0x10000];
uint32_t MIX16ToRGB32[0x10000];

uint32_t RGB16ToBGR32[0x10000];
uint32_t CRY16ToBGR32[0x10000];
uint32_t MIX16ToBGR32[0x10000];

// Straight from VJ 2.1. This isn't endian-safe.
-(void)fillColorLookupTables
{
    // NOTE: Jaguar 16-bit (non-CRY) color is RBG 556 like so:
    //       RRRR RBBB BBGG GGGG
    for(uint32_t i=0; i<0x10000; i++)
        RGB16ToRGB32[i] = 0x000000FF
        | ((i & 0xF800) << 16)                    // Red
        | ((i & 0x003F) << 18)                    // Green
        | ((i & 0x07C0) << 5);                    // Blue
    
    for(uint32_t i=0; i<0x10000; i++)
    {
        uint32_t cyan = (i & 0xF000) >> 12,
        red = (i & 0x0F00) >> 8,
        intensity = (i & 0x00FF);
        
        uint32_t r = (((uint32_t)redcv[cyan][red]) * intensity) >> 8,
        g = (((uint32_t)greencv[cyan][red]) * intensity) >> 8,
        b = (((uint32_t)bluecv[cyan][red]) * intensity) >> 8;
        
        CRY16ToRGB32[i] = 0x000000FF | (r << 24) | (g << 16) | (b << 8);
        MIX16ToRGB32[i] = (i & 0x01 ? RGB16ToRGB32[i] : CRY16ToRGB32[i]);
        
        CRY16ToBGR32[i] = 0x000000FF | (r << 8) | (g << 16) | (b << 24);
    }
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
        //printf(" Scanline %d of visible area |", (halfline - visible_halfline_start) / 2);
        
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
                //current_line_buffer[i] = bg_color;
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
#define HCLK_VISIBLE_LEFT (208 - 16 - 4)
#define HCLK_VISIBLE_RIGHT (HCLK_VISIBLE_LEFT + (320 * 4))
#define PWIDTH (((_registers->VMODE & 0x0E00) >> 9) + 1)

-(uint16_t)videoModePixelWidth
{
    return (HCLK_VISIBLE_RIGHT - HCLK_VISIBLE_LEFT) / PWIDTH;
}

-(void)renderLineCRY16:(uint32_t *)lineBuffer
{
    // Render the line buffer to the proper line in our MTLTexture.
    
    // Find which scanline we're at in the visible area.
    const uint16_t current_line = _registers->VC;
    const uint16_t visible_halfline_start = _registers->VDB;
    const uint16_t visible_area_scanline = (current_line - visible_halfline_start) / 2;
    
    // Calculate the starting pixel we're rendering at using HDB1 and PWIDTH.
    const uint16_t left_render_start = _registers->HDB1 / PWIDTH;
    const uint16_t visible_width = [self videoModePixelWidth] - left_render_start;
    
    JaguarScreen *screen = [[JaguarSystem sharedJaguar] Texture];
    id<MTLTexture> texture = [screen Texture];
    
    // Convert the line buffer from CRY16 to RGB32 (Metal's texture format)
    uint16_t *wordLineBuffer = (uint16_t *)lineBuffer;
    uint32_t rgb_buffer[LINE_BUFFER_WORD_WIDTH];
    for(int i=0;i<LINE_BUFFER_WORD_WIDTH;i++)
    {
        if(wordLineBuffer[i] != 0x0000)
        {
            uint8_t red     = redcv[(wordLineBuffer[i] & 0xF000) >> 12][(wordLineBuffer[i] & 0xF00) >> 8];
            uint8_t green   = greencv[(wordLineBuffer[i] & 0xF000) >> 12][(wordLineBuffer[i] & 0xF00) >> 8];
            uint8_t blue    = bluecv[(wordLineBuffer[i] & 0xF000) >> 12][(wordLineBuffer[i] & 0xF00) >> 8];
            
            //uint32_t rgb = blue | green << 8 | red << 16 | 0xFF000000;
            uint32_t rgb = red | green << 8 | blue << 16 | 0xFF000000;
            
            rgb_buffer[i] = rgb;
        }
        else
        {
            rgb_buffer[i] = 0xFF000000;
        }
        
    }
    const uint8_t *ptr_line_buffer_render_start = (uint8_t *)(rgb_buffer + left_render_start);
    
    MTLRegion region = MTLRegionMake2D(left_render_start, visible_area_scanline, visible_width, 1);
    [texture replaceRegion:region mipmapLevel:0 withBytes:ptr_line_buffer_render_start bytesPerRow:LBUF_bytesPerRow];
    
}

@end
