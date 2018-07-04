//
//  JaguarOPObject.h
//  Jagemu
//
//  Created by Kate on 7/3/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JaguarOPObject : NSObject

typedef enum op_object_t {
    JAGOP_BITMAP,
    JAGOP_SCALED,
    JAGOP_GPU,
    JAGOP_BRANCH,
    JAGOP_STOP
} OP_OBJECT_TYPE;

@property OP_OBJECT_TYPE object_type;

@end

/***/

@interface JaguarOPObjectBitmap : JaguarOPObject

@property uint16_t ypos;
@property uint16_t height;
@property uint32_t link;
@property uint32_t data;
@property uint16_t xpos;
@property uint8_t depth;
@property uint8_t pitch;
@property uint8_t dwidth;
@property uint8_t iwidth;
@property uint8_t index;
@property Boolean reflect;
@property Boolean rmw;
@property Boolean trans;
@property Boolean release_bus;
@property uint8_t firstpix;

-(instancetype)initWith:(uint64_t)phrase1 second:(uint64_t)phrase2;

@end

/***/

@interface JaguarOPObjectScaled : JaguarOPObjectBitmap

@property uint8_t hscale;
@property uint8_t vscale;
@property uint8_t remainder;

-(instancetype)initWith:(uint64_t)phrase1 second:(uint64_t)phrase2 third:(uint64_t)phrase3;

@end

/***/

@interface JaguarOPObjectGPU : JaguarOPObject

@property uint64_t data;

-(instancetype)initWith:(uint64_t)phrase;

@end

/***/

@interface JaguarOPObjectBranch : JaguarOPObject

@property uint16_t ypos;
@property uint8_t cc;
@property uint32_t link;

-(instancetype)initWith:(uint64_t)phrase;

@end

/***/

@interface JaguarOPObjectStop : JaguarOPObject

@property Boolean cpu_interrupt_flag;
@property uint64_t data;

-(instancetype)initWith:(uint64_t)phrase;

@end
