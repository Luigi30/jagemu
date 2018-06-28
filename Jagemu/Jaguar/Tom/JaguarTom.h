//
//  JaguarTom.h
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

/* Tom contains the blitter, object processor, memory controller, and a RISC GPU. */

#import <Foundation/Foundation.h>

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

@interface JaguarTom : NSObject {
    @public
    struct tom_registers_t *_registers;
}

@property struct tom_registers_t *registers;

-(instancetype)init;

@end
