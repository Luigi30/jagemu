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

#import "JaguarTomRegisters.h"
#import "JaguarObjectProcessor.h"

@interface JaguarTom : NSObject {
    @public
    struct tom_registers_t *_registers;
    JaguarObjectProcessor *_objectProcessor;
}

@property struct tom_registers_t *registers;
@property JaguarObjectProcessor *objectProcessor;

-(instancetype)init;

-(UInt16)getVideoOverscanWidth;

@end
