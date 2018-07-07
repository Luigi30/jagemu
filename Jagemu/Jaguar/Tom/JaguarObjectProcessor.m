//
//  JaguarObjectProcessor.m
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarObjectProcessor.h"
#import "JaguarTomRegisters.h"
#import "JaguarSystem.h"

@implementation JaguarObjectProcessor

-(instancetype)init:(struct tom_registers_t *)registers
{
    self = [super init];
    
    // Pointer to the Tom registers struct
    self.registers = registers;
    
    return self;
}

-(uint32_t)getLittleEndianOLP
{
    return ((_registers->OLP & 0xFFFF0000) >> 16) | ((_registers->OLP & 0x0000FFFF) << 16);
}

-(void)executeHalfLine;
{
    //debugging the object list routines
    //_registers->OLP = 0x21DC0;
    
    // Process the object list.
    JaguarMemory *memory = [[JaguarSystem sharedJaguar] Memory];
    
    JAGPTR object_list_head;
    uint16_t current_line = _registers->VC;
    
    // object list pointer is stored little-endian
    object_list_head = ((_registers->OLP & 0xFFFF0000) >> 16) | ((_registers->OLP & 0x0000FFFF) << 16);
    
    printf("OP: Processing object list at $%06X for vertical line count %d\n", object_list_head, current_line);
    
    uint32_t object_list_current = object_list_head;
    

    do
    {
        // Convert the object list into objects.
        uint32_t little_endian_olp = [self getLittleEndianOLP];
        
        JaguarOPObject *obj = [self parseOPObject:memory.WorkRAM+little_endian_olp];
        
        printf("OP: Parsing object at %06X\n", little_endian_olp);
        
        switch(obj.object_type)
        {
            case JAGOP_STOP:
                object_list_current = [self performStopObject:(JaguarOPObjectStop *)obj
                                                    currentOP:little_endian_olp];
                break;
            case JAGOP_BRANCH:
                object_list_current = [self performBranchObject:(JaguarOPObjectBranch *)obj
                                                      currentOP:little_endian_olp];
                break;
            case JAGOP_GPU:
                object_list_current = [self performGPUObject:(JaguarOPObjectGPU *)obj
                                                   currentOP:little_endian_olp];
                break;
            case JAGOP_SCALED:
                object_list_current = [self performScaledObject:(JaguarOPObjectScaled *)obj
                                                      currentOP:little_endian_olp];
                break;
            case JAGOP_BITMAP:
                object_list_current = [self performBitmapObject:(JaguarOPObjectBitmap *)obj
                                                      currentOP:little_endian_olp];
                break;
        }
        
        _registers->OLP = (_registers->OLP & 0xF) | ((object_list_current) << 3);
    }
    while(object_list_current != 0);
    
}

- (JaguarOPObject *) parseOPObject:(uint8_t *)op_object
{
    // Grab the first phrase and use it to determine the object type.
    
    @try
    {
        
        uint64_t phrase, phrase2, phrase3;
        memcpy(&phrase, op_object, 8);
        
        //TODO: set OB0-OB3
        
        OP_OBJECT_TYPE t = phrase & 0x7;
        JaguarOPObject *obj;
        
        //TODO: STOP objects are not being recognized for some reason
        
        switch(t)
        {
            case JAGOP_STOP:
                obj = [[JaguarOPObjectStop alloc] initWith:phrase];
                break;
            case JAGOP_BRANCH:
                obj = [[JaguarOPObjectBranch alloc] initWith:phrase];
                break;
            case JAGOP_GPU:
                obj = [[JaguarOPObjectGPU alloc] initWith:phrase];
                break;
            case JAGOP_BITMAP:
                memcpy(&phrase2, op_object+8, 8);
                obj = [[JaguarOPObjectBitmap alloc] initWith:phrase second:phrase2];
                break;
            case JAGOP_SCALED:
                memcpy(&phrase2, op_object+8, 8);
                memcpy(&phrase3, op_object+16, 8);
                obj = [[JaguarOPObjectScaled alloc] initWith:phrase second:phrase2 third:phrase3];
                break;
        }
        
        return obj;
    }
    @catch (NSException * e)
    {
        NSLog(@"OP: Exception parsing an OP object: %@", e);
        return nil;
    }
}

/* OP object functions */
-(uint32_t)performBitmapObject:(JaguarOPObjectBitmap *)op_object currentOP:(uint32_t)current
{
    printf("OP: %d bpp %d x %d bitmap object at (%d,%d)\n",
           1 << op_object.depth,
           op_object.dwidth*8 * (8 / (1 << op_object.depth)),
           op_object.height,
           op_object.xpos,
           op_object.ypos);
    return op_object.link;
}

-(uint32_t)performScaledObject:(JaguarOPObjectScaled *)op_object currentOP:(uint32_t)current
{
    printf("OP: %d bpp %d x %d scaled object at X position %d\n",
           1 << op_object.depth,
           op_object.dwidth*8 * (8 / (1 << op_object.depth)),
           op_object.height,
           op_object.xpos,
           op_object.ypos);
    return op_object.link;
}

-(uint32_t)performGPUObject:(JaguarOPObjectGPU *)op_object currentOP:(uint32_t)current
{
    // TODO: check endianness against real hardware
    _registers->OB0 = (op_object.data & 0xFFFF000000000000) >> 48;
    _registers->OB1 = (op_object.data & 0x0000FFFF00000000) >> 32;
    _registers->OB2 = (op_object.data & 0x00000000FFFF0000) >> 16;
    _registers->OB3 = (op_object.data & 0x000000000000FFFF);
    
    // TODO: fire interrupt off to the GPU
    printf("TODO: fire GPU interrupt\n");
    
    // advance to next object
    _registers->OLP = _registers->OLP + 8;
    return _registers->OLP >> 3;
}
-(uint32_t)performBranchObject:(JaguarOPObjectBranch *)op_object currentOP:(uint32_t)current
{
    uint16_t vc = _registers->VC;
    
    if(op_object.cc == OP_YPOS_EQ_VC)
    {
        //YPOS == VC or YPOS == 0x7FF
        if(op_object.ypos == vc || op_object.ypos == 0x7FF)
        {
            return op_object.link;
        }
    }
    else if(op_object.cc == OP_YPOS_GT_VC)
    {
        //YPOS > VC
        if(op_object.ypos > vc)
        {
            return op_object.link;
        }
    }
    else if(op_object.cc == OP_YPOS_LT_VC)
    {
        //YPOS < VC
        if(op_object.ypos < vc)
        {
            return op_object.link;
        }
    }
    else if(op_object.cc == OP_FLAG_IS_SET)
    {
        //Object Processor flag is set
        if(_registers->OBF & 0x1)
        {
            return op_object.link;
        }
    }
    else if(op_object.cc == OP_SECOND_HALF_OF_SCANLINE)
    {
        // Second half of scanline (HC.10 = 1)
        if(_registers->HC & 0x400)
        {
            return op_object.link;
        }
    }
    else
    {
        printf("Branch object has invalid condition code: %d\n", op_object.cc);
        return 0; // terminate processing
    }
    
    _registers->OLP = _registers->OLP + 8;
    return _registers->OLP >> 3; // next phrase
}

-(uint32_t)performStopObject:(JaguarOPObjectStop *)op_object currentOP:(uint32_t)current
{
    // TODO: check endianness against real hardware.
    // TODO: figure out what the CPU interrupt flag does, exactly
    
    _registers->OB0 = (op_object.data & 0xFFFF000000000000) >> 48;
    _registers->OB1 = (op_object.data & 0x0000FFFF00000000) >> 32;
    _registers->OB2 = (op_object.data & 0x00000000FFFF0000) >> 16;
    _registers->OB3 = (op_object.data & 0x000000000000FFFF);
    
    return 0; // terminate processing
}

@end
