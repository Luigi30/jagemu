//
//  TomRegisters.h
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LINE_BUFFER_LONG_WIDTH 360
#define LINE_BUFFER_WORD_WIDTH 360*2
#define LINE_BUFFER_BYTE_WIDTH 360*4

// VMODE register flags.
typedef enum vmode_flags_t {
    VIDEN = 0x0001,         // Enable video time base generator
    
    // Graphics mode
    CRY16 = 0x0000,         // 16-bit CRY
    RGB24 = 0x0002,         // 24-bit RGB
    DIRECT16 = 0x0004,      // 16-bit DIRECT
    RGB16 = 0x0006,         // 16-bit RGB
    
    GENLOCK = 0x0008,       // Genlock - not supported in Jaguar console
    INCEN = 0x0010,         // Video source encrustation
    BINC = 0x0020,          // If encrustation is enabled, select local border color
    CSYNC = 0x0040,         // Enable composite sync
    BGEN = 0x0080,          // Enable background color
    VARMOD = 0x0100,        // Variable color resolution mode
    
    PWIDTH1 = 0x0000,       // Pixel width in video clock cycles.
    PWIDTH2 = 0x0200,       // Display width should be a multiple of the selected pixel width.
    PWIDTH3 = 0x0400,
    PWIDTH4 = 0x0600,
    PWIDTH5 = 0x0800,
    PWIDTH6 = 0x0A00,
    PWIDTH7 = 0x0C00,
    PWIDTH8 = 0x0E00
} VMODE_FLAGS;

struct tom_registers_t {
    /* $F00000... */
    uint16_t    MEMCON1;
    uint16_t    MEMCON2;
    uint16_t    HC;
    uint16_t    VC;
    uint16_t    LPH;
    uint16_t    LPV;
    uint16_t    OB0;
    uint16_t    OB1;
    uint16_t    OB2;
    uint16_t    OB3;
    uint32_t    OLP;
    uint16_t    OBF;
    uint16_t    VMODE;
    uint16_t    BORD1;
    uint16_t    BORD2;
    uint16_t    HP;
    uint16_t    HBB;
    uint16_t    HBE;
    uint16_t    HS;
    uint16_t    HVS;
    uint16_t    HDB1;
    uint16_t    HDB2;
    uint16_t    HDE;
    uint16_t    VP;
    uint16_t    VBB;
    uint16_t    VBE;
    uint16_t    VS;
    uint16_t    VDB;
    uint16_t    VDE;
    uint16_t    VEB;
    uint16_t    VEE;
    uint16_t    VI;
    uint16_t    PIT0;
    uint16_t    PIT1;
    uint16_t    HEQ;
    uint16_t    BG;
    
    /* $F000E0... */
    uint16_t    INT1;
    uint16_t    INT2;
    
    /* $F00400-$F007FE */
    uint16_t    CLUT[512];
    
    uint32_t    LBUF_A[360]; // Line Buffer A
    uint32_t    LBUF_B[360]; // Line Buffer B
    uint32_t    *LBUF_ACTIVE; // points to the currently active line buffer
};
