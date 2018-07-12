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

typedef enum op_condition_code_t {
    OP_YPOS_EQ_VC = 0,
    OP_YPOS_GT_VC = 1,
    OP_YPOS_LT_VC = 2,
    OP_FLAG_IS_SET = 3,
    OP_SECOND_HALF_OF_SCANLINE = 4
} OP_CONDITION_CODE;

typedef enum op_pixel_depth_t {
    OP_DEPTH_1BPP = 0,
    OP_DEPTH_2BPP = 1,
    OP_DEPTH_4BPP = 2,
    OP_DEPTH_8BPP = 3,
    OP_DEPTH_16BPP= 4,
    OP_DEPTH_32BPP= 5
} OP_PIXEL_DEPTH;

@interface JaguarOPObjectBranch : JaguarOPObject

@property uint16_t ypos;
@property OP_CONDITION_CODE cc;
@property uint32_t link;

-(instancetype)initWith:(uint64_t)phrase;

@end

/***/

@interface JaguarOPObjectStop : JaguarOPObject

@property Boolean cpu_interrupt_flag;
@property uint64_t data;

-(instancetype)initWith:(uint64_t)phrase;

@end
