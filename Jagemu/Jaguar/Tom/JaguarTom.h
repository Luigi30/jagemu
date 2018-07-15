//
//  JaguarTom.h
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

/* Tom contains the blitter, object processor, memory controller, and a RISC GPU.
 *
 * The pixel path is:
 * Object Processor -> Line Buffer -> Pixel Generator -> Video Timer
 */

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#import "JaguarBlitter.h"
#import "JaguarBlitter+Registers.h"
#import "JaguarTomRegisters.h"
#import "JaguarObjectProcessor.h"

extern const NSUInteger LBUF_bytesPerPixel;
extern const NSUInteger LBUF_bytesPerRow;

@interface JaguarTom : NSObject {
    @public
    struct tom_registers_t *_registers;
    JaguarObjectProcessor *_objectProcessor;
    JaguarBlitter *_blitter;
}

@property struct tom_registers_t *registers;

@property JaguarObjectProcessor *objectProcessor;
@property JaguarBlitter *blitter;

-(instancetype)init;

// Reset Tom, the OP, the Blitter, and all Tom registers to their defaults.
-(void)reset;

-(void)executeHalfLine;

-(UInt16)getVideoOverscanWidth;

-(void)updateInterrupts;

@end
