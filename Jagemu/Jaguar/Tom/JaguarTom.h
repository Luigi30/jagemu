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

#import "JaguarTomRegisters.h"
#import "JaguarObjectProcessor.h"

extern const NSUInteger LBUF_bytesPerPixel;
extern const NSUInteger LBUF_bytesPerRow;

@interface JaguarTom : NSObject {
    @public
    struct tom_registers_t *_registers;
    JaguarObjectProcessor *_objectProcessor;
}

@property struct tom_registers_t *registers;
@property JaguarObjectProcessor *objectProcessor;

-(instancetype)init;

// Reset Tom, the OP, the Blitter, and all Tom registers to their defaults.
-(void)reset;

-(void)executeHalfLine;

-(UInt16)getVideoOverscanWidth;
-(uint16_t)videoModePixelWidth;

/* rendering functions */
-(void)renderLineCRY16:(uint32_t *)lineBuffer;

@end
