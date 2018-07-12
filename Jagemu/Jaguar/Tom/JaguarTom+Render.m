//
//  JaguarTom+Render.m
//  Jagemu
//
//  Created by Kate on 7/11/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarSystem.h"
#import "JaguarTom+Render.h"

@implementation JaguarTom (Render)

#define HCLK_VISIBLE_LEFT (208 - 16 - 4)
#define HCLK_VISIBLE_RIGHT (HCLK_VISIBLE_LEFT + (320 * 4))
#define PWIDTH (((_registers->VMODE & 0x0E00) >> 9) + 1)

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
            uint8_t red     = (redcv[(wordLineBuffer[i] & 0xF000) >> 12][(wordLineBuffer[i] & 0xF00) >> 8] / 255.0) * (wordLineBuffer[i] & 0xFF);
            uint8_t green   = (greencv[(wordLineBuffer[i] & 0xF000) >> 12][(wordLineBuffer[i] & 0xF00) >> 8] / 255.0) * (wordLineBuffer[i] & 0xFF);
            uint8_t blue    = (bluecv[(wordLineBuffer[i] & 0xF000) >> 12][(wordLineBuffer[i] & 0xF00) >> 8] / 255.0) * (wordLineBuffer[i] & 0xFF);
            rgb_buffer[i] = red | green << 8 | blue << 16 | 0xFF000000;
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

//
// Red Color Values for CrY<->RGB Color Conversion
//
uint8_t redcv[16][16] = {
    //  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    // ----------------------------------------------------------------------
    {  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0},    // 0
    {  34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 19, 0},    // 1
    {  68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 64, 43, 21, 0},    // 2
    {  102,102,102,102,102,102,102,102,102,102,102,95, 71, 47, 23, 0},    // 3
    {  135,135,135,135,135,135,135,135,135,135,130,104,78, 52, 26, 0},    // 4
    {  169,169,169,169,169,169,169,169,169,170,141,113,85, 56, 28, 0},    // 5
    {  203,203,203,203,203,203,203,203,203,183,153,122,91, 61, 30, 0},    // 6
    {  237,237,237,237,237,237,237,237,230,197,164,131,98, 65, 32, 0},    // 7
    {  255,255,255,255,255,255,255,255,247,214,181,148,15, 82, 49, 7},    // 8
    {  255,255,255,255,255,255,255,255,255,235,204,173,143,112,81, 51},   // 9
    {  255,255,255,255,255,255,255,255,255,255,227,198,170,141,113,85},   // A
    {  255,255,255,255,255,255,255,255,255,255,249,223,197,171,145,119},  // B
    {  255,255,255,255,255,255,255,255,255,255,255,248,224,200,177,153},  // C
    {  255,255,255,255,255,255,255,255,255,255,255,255,252,230,208,187},  // D
    {  255,255,255,255,255,255,255,255,255,255,255,255,255,255,240,221},  // E
    {  255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255}   // F
};

//
// Green Color Values for CrY<->RGB Color Conversion
//
uint8_t greencv[16][16] = {
    //  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    // ----------------------------------------------------------------------
    {  0,  17, 34, 51,68, 85, 102,119,136,153,170,187,204,221,238,255},   // 0
    {  0,  19, 38, 57,77, 96, 115,134,154,173,192,211,231,250,255,255},   // 1
    {  0,  21, 43, 64,86, 107,129,150,172,193,215,236,255,255,255,255},   // 2
    {  0,  23, 47, 71,95, 119,142,166,190,214,238,255,255,255,255,255},   // 3
    {  0,  26, 52, 78,104,130,156,182,208,234,255,255,255,255,255,255},   // 4
    {  0,  28, 56, 85,113,141,170,198,226,255,255,255,255,255,255,255},   // 5
    {  0,  30, 61, 91,122,153,183,214,244,255,255,255,255,255,255,255},   // 6
    {  0,  32, 65, 98,131,164,197,230,255,255,255,255,255,255,255,255},   // 7
    {  0,  32, 65, 98,131,164,197,230,255,255,255,255,255,255,255,255},   // 8
    {  0,  30, 61, 91,122,153,183,214,244,255,255,255,255,255,255,255},   // 9
    {  0,  28, 56, 85,113,141,170,198,226,255,255,255,255,255,255,255},   // A
    {  0,  26, 52, 78,104,130,156,182,208,234,255,255,255,255,255,255},   // B
    {  0,  23, 47, 71,95, 119,142,166,190,214,238,255,255,255,255,255},   // C
    {  0,  21, 43, 64,86, 107,129,150,172,193,215,236,255,255,255,255},   // D
    {  0,  19, 38, 57,77, 96, 115,134,154,173,192,211,231,250,255,255},   // E
    {  0,  17, 34, 51,68, 85, 102,119,136,153,170,187,204,221,238,255}    // F
};

//
// Blue Color Values for CrY<->RGB Color Conversion
//
uint8_t bluecv[16][16] = {
    //  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    // ----------------------------------------------------------------------
    {  255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255},  // 0
    {  255,255,255,255,255,255,255,255,255,255,255,255,255,255,240,221},  // 1
    {  255,255,255,255,255,255,255,255,255,255,255,255,252,230,208,187},  // 2
    {  255,255,255,255,255,255,255,255,255,255,255,248,224,200,177,153},  // 3
    {  255,255,255,255,255,255,255,255,255,255,249,223,197,171,145,119},  // 4
    {  255,255,255,255,255,255,255,255,255,255,227,198,170,141,113,85},   // 5
    {  255,255,255,255,255,255,255,255,255,235,204,173,143,112,81, 51},   // 6
    {  255,255,255,255,255,255,255,255,247,214,181,148,115,82, 49, 17},   // 7
    {  237,237,237,237,237,237,237,237,230,197,164,131,98, 65, 32, 0},    // 8
    {  203,203,203,203,203,203,203,203,203,183,153,122,91, 61, 30, 0},    // 9
    {  169,169,169,169,169,169,169,169,169,170,141,113,85, 56, 28, 0},    // A
    {  135,135,135,135,135,135,135,135,135,135,130,104,78, 52, 26, 0},    // B
    {  102,102,102,102,102,102,102,102,102,102,102,95, 71, 47, 23, 0},    // C
    {  68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 64, 43, 21, 0},    // D
    {  34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 19, 0},    // E
    {  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0}     // F
};
