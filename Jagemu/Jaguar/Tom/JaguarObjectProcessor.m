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

-(uint32_t)getWordSwappedOLP
{
    return ((_registers->OLP & 0xFFFF0000) >> 16) | ((_registers->OLP & 0x0000FFFF) << 16);
}

-(void)executeHalfLine;
{
    // Process the object list.
    JaguarMemory *memory = [[JaguarSystem sharedJaguar] Memory];
    
    JAGPTR object_list_head;
    uint16_t current_line = _registers->VC;
    
    // object list pointer is stored little-endian
    object_list_head = [self getWordSwappedOLP];
    
    printf("OP: Processing object list at $%06X for vertical line count %d\n", object_list_head, current_line);
    
    uint32_t object_list_current = object_list_head;
    uint32_t new_object_list_ptr;
    
    do
    {
        // Convert the object list into objects.
        JaguarOPObject *obj = [self parseOPObject:memory.WorkRAM+object_list_current];
        
        printf("OP: Parsing object at %06X\n", object_list_current);
        
        switch(obj.object_type)
        {
            case JAGOP_STOP:
                new_object_list_ptr = [self performStopObject:(JaguarOPObjectStop *)obj
                                                    currentOP:object_list_current];
                break;
            case JAGOP_BRANCH:
                new_object_list_ptr = [self performBranchObject:(JaguarOPObjectBranch *)obj
                                                      currentOP:object_list_current];
                break;
            case JAGOP_GPU:
                new_object_list_ptr = [self performGPUObject:(JaguarOPObjectGPU *)obj
                                                   currentOP:object_list_current];
                break;
            case JAGOP_SCALED:
                new_object_list_ptr = [self performScaledObject:(JaguarOPObjectScaled *)obj
                                                      currentOP:object_list_current];
                break;
            case JAGOP_BITMAP:
                new_object_list_ptr = [self performBitmapObject:(JaguarOPObjectBitmap *)obj
                                                      currentOP:object_list_current];
                break;
        }
        
        
        uint32_t olp = [MathHelper swapWordsOfLong:(new_object_list_ptr)];
        object_list_current = (olp & 0xF) | (new_object_list_ptr << 3);
    }
    while(object_list_current != 0);
    
    // Render a scanline in the correct color mode.
    switch(_registers->VMODE & 0x6)
    {
        case 0x00:
            [[[JaguarSystem sharedJaguar] Tom] renderLineCRY16:(_registers->LBUF_ACTIVE)];
            break;
        case 0x02:
            printf(" RGB24 mode not yet supported");
            break;
        case 0x04:
            printf(" DIRECT16 mode not yet supported");
            break;
        case 0x06:
            printf(" RGB16 mode not yet supported");
            break;
        default:
            printf(" Invalid video mode ");
            break;
    }
}

- (JaguarOPObject *) parseOPObject:(uint8_t *)op_object
{
    // Grab the first phrase and use it to determine the object type.
    
    @try
    {
        uint64_t phrase, phrase2, phrase3;
        memcpy(&phrase, op_object, 8);
     
        phrase = CFSwapInt64HostToBig(phrase);
        
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
                phrase2 = CFSwapInt64HostToBig(phrase2);
                obj = [[JaguarOPObjectBitmap alloc] initWith:phrase second:phrase2];
                break;
            case JAGOP_SCALED:
                memcpy(&phrase2, op_object+8, 8);
                memcpy(&phrase3, op_object+16, 8);
                
                phrase2 = CFSwapInt64HostToBig(phrase2);
                phrase3 = CFSwapInt64HostToBig(phrase3);
                
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
    JaguarMemory *memory = [[JaguarSystem sharedJaguar] Memory];
    
    uint16_t pixel_width = (int)(op_object.dwidth*8 * (8 / (double)(1 << op_object.depth)));
    
    printf("OP: %d bpp %d x %d bitmap object w/coords (%d,%d) at %06X in memory. (%06X)\n",
           1 << op_object.depth,
           pixel_width,
           op_object.height,
           op_object.xpos,
           op_object.ypos,
           (op_object.data << 3),
           current);
    
    Boolean object_is_on_this_scanline = false;
    if(op_object.ypos <= _registers->VC && op_object.height > 0)
    {
        object_is_on_this_scanline = true;
        
        uint8_t *lbuf_bytes = (uint8_t *)_registers->LBUF_ACTIVE;
        uint16_t *lbuf_words = (uint16_t *)_registers->LBUF_ACTIVE;
        
        uint16_t pixel_pointer = 0;
        
        // ...render...
        switch(op_object.depth)
        {
            case 0: // 1BPP
                break;
            case 1: // 2BPP
                break;
            case 2: // 4BPP
                break;
            case 3: // 8BPP
                break;
            case 4: // 16BPP
                for(int i=op_object.xpos; i<op_object.xpos+pixel_width; i++)
                {
                    uint8_t high = *(memory.WorkRAM + (op_object.data << 3) + pixel_pointer);
                    uint8_t low = *(memory.WorkRAM + (op_object.data << 3) + pixel_pointer + 1);
                    
                    if(high != 0x00 && low != 0x00)
                    {
                        
                    }
                    
                    lbuf_bytes[i*2] = low;
                    lbuf_bytes[i*2 + 1] = high;
                    
                    pixel_pointer += 2;
                }
                break;
            case 5: // 32BPP
                break;
        }

        
        // Update a few fields after we render this scanline.
        if(_registers->VP & 0x01)  // double-check this flag
            op_object.height -= 1; // Non-interlaced = subtract 1 from height per scanline
        else
            op_object.height -= 2; // Interlaced = subtract 2 from height per scanline
        
        if(op_object.height < 0)
            op_object.height = 0; //never let this go negative
        
        op_object.data = op_object.data + ((8 * op_object.dwidth) >> 3); // Advance data pointer after each scanline.
        
        // Get phrase1 of the OP object and update it.
        JaguarMemory *memory = [[JaguarSystem sharedJaguar] Memory];
        
        uint64_t phrase;
        memcpy(&phrase, memory.WorkRAM+current, 8);
        phrase = CFSwapInt64HostToBig(phrase);
        
        phrase = phrase & 0x000007FFFF003FFF;
        phrase |= op_object.height << 14;
        
        phrase |= (uint64_t)op_object.data << 43;
        
        phrase = CFSwapInt64BigToHost(phrase);
        memcpy(memory.WorkRAM+current, &phrase, 8);
    }
    
    return (op_object.link);
}

-(uint32_t)performScaledObject:(JaguarOPObjectScaled *)op_object currentOP:(uint32_t)current
{
    printf("OP: %d bpp %d x %d scaled object at X position (%d,%d)\n",
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
