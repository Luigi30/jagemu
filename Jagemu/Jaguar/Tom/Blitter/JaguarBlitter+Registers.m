//
//  JaguarBlitter+Registers.m
//  Jagemu
//
//  Created by Kate on 7/14/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarBlitter+Registers.h"
#import "JaguarSystem.h"

@implementation JaguarBlitter (Registers)

// TODO: test all these reads and writes

-(void)putRegisterAtOffset:(uint8_t)offset value:(uint64_t)value width:(int)width
{
    uint8_t write_offset = 0;
    uint64_t write_value = 0;
    
    switch(width)
    {
        case 1:
            value = value & 0xFF;
            
            switch(offset & 0x03)
            {
                // Byte writes don't need to be aligned.
                case 0:
                    write_offset = offset;
                    write_value = ([self getRegisterAtOffset:offset width:4] & 0x00FFFFFF) | (value << 24);
                    break;
                case 1:
                    write_offset = offset & 0xFC;
                    write_value = ([self getRegisterAtOffset:offset width:4] & 0xFF00FFFF) | (value << 16);
                    break;
                case 2:
                    write_offset = offset & 0xFC;
                    write_value = ([self getRegisterAtOffset:offset width:4] & 0xFFFF00FF) | (value << 8);
                    break;
                case 3:
                    write_offset = offset & 0xFC;
                    write_value = ([self getRegisterAtOffset:offset width:4] & 0xFFFFFF00) | (value << 0);
                    break;
            }
            break;
        case 2:
            value = value & 0xFFFF;
            
            switch(offset & 0x03)
            {
                case 0:
                    // Write is long-aligned. Write to the high word of the long.
                    write_offset = offset & 0xFC;
                    write_value = ((value & 0x0000FFFF) << 16) | ([self getRegisterAtOffset:offset & 0xFC width:4] & 0x0000FFFF);
                case 1:
                    // Write is unaligned, bus error.
                    NSLog(@"TODO: unaligned write to blitter regs, boom\n");
                case 2:
                    // Write is word-aligned. Write to the low word of the long.
                    write_offset = offset & 0xFC;
                    write_value = ([self getRegisterAtOffset:offset & 0xFC width:4] & 0xFFFF0000) | (value & 0x0000FFFF);
                case 3:
                    // Write is unaligned, bus error.
                    NSLog(@"TODO: unaligned write to blitter regs, boom\n");
                    break;
            }
            break;
        case 4:
            if(offset & 0x03)
            {
                NSLog(@"TODO: unaligned write to blitter regs, boom\n");
            }
            else
            {
                // Write directly to the long.
                write_offset = offset;
                write_value = value;
            }
            break;
        case 8:
            // Split a phrase write into two long writes.
            [self putRegisterAtOffset:offset+0 value:value & 0xFFFFFFFF00000000 width:4];
            [self putRegisterAtOffset:offset+4 value:value & 0x00000000FFFFFFFF width:4];
            break;
    }
    
    switch(write_offset)
    {
        case 0x0:
            _registers->A1_BASE     = write_value & 0xFFFFFFFF;
            break;
        case 0x4:
            _registers->A1_FLAGS    = write_value & 0xFFFFFFFF;
            break;
        case 0x8:
            _registers->A1_CLIP     = write_value & 0xFFFFFFFF;
            break;
        case 0xC:
            _registers->A1_PIXEL    = write_value & 0xFFFFFFFF;
            break;
        case 0x10:
            _registers->A1_STEP     = write_value & 0xFFFFFFFF;
            break;
        case 0x14:
            _registers->A1_FSTEP    = write_value & 0xFFFFFFFF;
            break;
        case 0x18:
            _registers->A1_FPIXEL   = write_value & 0xFFFFFFFF;
            break;
        case 0x1C:
            _registers->A1_INC      = write_value & 0xFFFFFFFF;
            break;
        case 0x20:
            _registers->A1_FINC     = write_value & 0xFFFFFFFF;
            break;
        case 0x24:
            _registers->A2_BASE     = write_value & 0xFFFFFFFF;
            break;
        case 0x28:
            _registers->A2_FLAGS    = write_value & 0xFFFFFFFF;
            break;
        case 0x2C:
            _registers->A2_MASK     = write_value & 0xFFFFFFFF;
            break;
        case 0x30:
            _registers->A2_PIXEL    = write_value & 0xFFFFFFFF;
            break;
        case 0x34:
            _registers->A2_STEP     = write_value & 0xFFFFFFFF;
            break;
        case 0x38:
            _registers->B_CMD       = write_value & 0xFFFFFFFF;
            [[[[JaguarSystem sharedJaguar] Tom] blitter] triggerBlitterActivation];
            break;
        case 0x3C:
            _registers->B_COUNT     = write_value & 0xFFFFFFFF;
            break;
            
        // Data registers. Set up reads every 32 bits as an optimization.
        case 0x40:
            _registers->B_SRCD  = (write_value << 32) | (_registers->B_SRCD & 0x00000000FFFFFFFF);
            break;
        case 0x44:
            _registers->B_SRCD  = (_registers->B_SRCD & 0xFFFFFFFF00000000) | (write_value & 0x00000000FFFFFFFF);
            break;
        case 0x48:
            _registers->B_DSTD  = (write_value << 32) | (_registers->B_SRCD & 0x00000000FFFFFFFF);
            break;
        case 0x4C:
            _registers->B_DSTD  = (_registers->B_SRCD & 0xFFFFFFFF00000000) | (write_value & 0x00000000FFFFFFFF);
            break;
        case 0x50:
            _registers->B_DSTZ  = (write_value << 32) | (_registers->B_SRCD & 0x00000000FFFFFFFF);
            break;
        case 0x54:
            _registers->B_DSTZ  = (_registers->B_SRCD & 0xFFFFFFFF00000000) | (write_value & 0x00000000FFFFFFFF);
            break;
        case 0x58:
            _registers->B_SRCZ1 = (write_value << 32) | (_registers->B_SRCD & 0x00000000FFFFFFFF);
            break;
        case 0x5C:
            _registers->B_SRCZ1 = (_registers->B_SRCD & 0xFFFFFFFF00000000) | (write_value & 0x00000000FFFFFFFF);
            break;
        case 0x60:
            _registers->B_SRCZ2 = (write_value << 32) | (_registers->B_SRCD & 0x00000000FFFFFFFF);
            break;
        case 0x64:
            _registers->B_SRCZ2 = (_registers->B_SRCD & 0xFFFFFFFF00000000) | (write_value & 0x00000000FFFFFFFF);
            break;
        case 0x68:
            _registers->B_PATD  = (write_value << 32) | (_registers->B_SRCD & 0x00000000FFFFFFFF);
            break;
        case 0x6C:
            _registers->B_PATD  = (_registers->B_SRCD & 0xFFFFFFFF00000000) | (write_value & 0x00000000FFFFFFFF);
            break;
        case 0x70:
            _registers->B_IINC  = write_value & 0xFFFFFFFF;
            break;
        case 0x74:
            _registers->B_ZINC  = write_value & 0xFFFFFFFF;
            break;
        case 0x78:
            _registers->B_STOP  = write_value & 0xFFFFFFFF;
            break;
    }
}

-(uint32_t)getRegisterAtOffset:(uint8_t)offset width:(int)width
{
    // Offset from $F02200.
    
    uint8_t read_offset = offset & 0xFC;
    uint64_t read_value = 0;
    
    switch(read_offset)
    {
        case 0x0:
            read_value = _registers->A1_BASE;
            break;
        case 0x4:
            read_value = _registers->A1_FLAGS;
            break;
        case 0x8:
            read_value = _registers->A1_CLIP;
            break;
        case 0xC:
            read_value = _registers->A1_PIXEL;
            break;
        case 0x10:
            read_value = _registers->A1_STEP;
            break;
        case 0x14:
            read_value = _registers->A1_FSTEP;
            break;
        case 0x18:
            read_value = _registers->A1_FPIXEL;
            break;
        case 0x1C:
            read_value = _registers->A1_INC;
            break;
        case 0x20:
            read_value = _registers->A1_FINC;
            break;
        case 0x24:
            read_value = _registers->A2_BASE;
            break;
        case 0x28:
            read_value = _registers->A2_FLAGS;
            break;
        case 0x2C:
            read_value = _registers->A2_MASK;
            break;
        case 0x30:
            read_value = _registers->A2_PIXEL;
            break;
        case 0x34:
            read_value = _registers->A2_STEP;
            break;
        case 0x38:
            read_value = [self buildBCMDRead];
            break;
        case 0x3C:
            read_value = _registers->B_COUNT;
            break;
            
        // Data registers. Set up reads every 32 bits as an optimization.
        case 0x40:
            read_value = (_registers->B_SRCD & 0xFFFFFFFF00000000) >> 32;
            break;
        case 0x44:
            read_value = _registers->B_SRCD & 0x00000000FFFFFFFF;
            break;
        case 0x48:
            read_value = (_registers->B_DSTD & 0xFFFFFFFF00000000) >> 32;
            break;
        case 0x4C:
            read_value = _registers->B_DSTD & 0x00000000FFFFFFFF;
            break;
        case 0x50:
            read_value = (_registers->B_DSTZ & 0xFFFFFFFF00000000) >> 32;
            break;
        case 0x54:
            read_value = _registers->B_DSTZ & 0x00000000FFFFFFFF;
            break;
        case 0x58:
            read_value = (_registers->B_SRCZ1 & 0xFFFFFFFF00000000) >> 32;
            break;
        case 0x5C:
            read_value = _registers->B_SRCZ1 & 0x00000000FFFFFFFF;
            break;
        case 0x60:
            read_value = (_registers->B_SRCZ2 & 0xFFFFFFFF00000000) >> 32;
            break;
        case 0x64:
            read_value = _registers->B_SRCZ2 & 0x00000000FFFFFFFF;
            break;
        case 0x68:
            read_value = (_registers->B_PATD & 0xFFFFFFFF00000000) >> 32;
            break;
        case 0x6C:
            read_value = _registers->B_PATD & 0x00000000FFFFFFFF;
            break;
        case 0x70:
            read_value = _registers->B_IINC;
            break;
        case 0x74:
            read_value = _registers->B_ZINC;
            break;
        case 0x78:
            read_value = _registers->B_STOP;
            break;
        default:
            NSLog(@"JaguarBlitter getRegisterAtOffset: offset %x out of range", offset);
            return 0;
            break;
    }

    switch(width)
    {
        case 1:
            return (read_value & (0xFF000000 >> (8 * (offset & 0x03)))) >> (24 - (8 * (offset & 0x03)));
            break;
        case 2:
            return (read_value & (0xFFFF << (offset & 0x02))) >> (16 * (offset & 0x02));
            break;
        case 4:
            return read_value & 0xFFFFFFFF;
            break;
    }
    
    return 0;
    
}

@end
