//
//  JaguarTom+RegisterLookup.m
//  Jagemu
//
//  Created by Kate on 7/6/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarTom+RegisterLookup.h"

@implementation JaguarTom (RegisterLookup)

// TODO: the CLUT being a uint16 is dumb, change it to a uint8 so we get free unaligned writes and all that

-(uint32_t)getClutLongByOffset:(uint32_t)offset
{
    printf("Unimplemented: getClutLongByOffset\n");
    return 0x0;
}

-(uint16_t)getClutWordByOffset:(uint32_t)offset
{
    return _registers->CLUT[offset >> 1];
}

-(uint8_t)getClutByteByOffset:(uint32_t)offset
{
    // TODO: check these addresses
    if(offset & 0x01)
    {
        return _registers->CLUT[(offset & 0xFFFE) >> 1] & 0x00FF;
    }
    else
    {
        return _registers->CLUT[(offset & 0xFFFE) >> 1] & 0xFF00;
    }
}

// Write a long to the CLUT - writes affect CLUT A and CLUT B.
-(void)putClutLongByOffset:(uint32_t)offset value:(uint32_t)value
{
    printf("Unimplemented: putClutLongByOffset\n");
}

// Write a word to the CLUT - writes affect CLUT A and CLUT B.
-(void)putClutWordByOffset:(uint32_t)offset value:(uint16_t)value
{
    // TODO: unaligned writes
    _registers->CLUT[(offset >> 1) & 0xEFF] = value;
    _registers->CLUT[(offset >> 1) | 0x100] = value;
}

// Write a byte to the CLUT - writes affect CLUT A and CLUT B.
-(void)putClutByteByOffset:(uint32_t)offset value:(uint8_t)value
{
    // TODO: unaligned writes
    if(offset & 0x01)
    {
        // Write the low byte.
        uint16_t word = offset & 0xFE;
        _registers->CLUT[(word >> 1) & 0xEFF] = (_registers->CLUT[(word >> 1) & 0xEFF] & 0xFF00) | value;
        _registers->CLUT[(word >> 1) | 0x100] = (_registers->CLUT[(word >> 1) | 0x100] & 0xFF00) | value;
    }
    else
    {
        // Write the high byte.
        _registers->CLUT[(offset >> 1) & 0xEFF] = (_registers->CLUT[(offset >> 1) & 0xEFF] & 0x00FF) | (value << 8);
        _registers->CLUT[(offset >> 1) | 0x100] = (_registers->CLUT[(offset >> 1) | 0x100] & 0x00FF) | (value << 8);
    }
}


/* Register functions */
-(uint32_t)getRegisterLongByOffset:(uint32_t)address
{
    return [self getRegisterAtOffset:address];
}

-(uint16_t)getRegisterWordByOffset:(uint32_t)address
{
    return [self getRegisterAtOffset:address] & 0xFFFF;
}

-(uint8_t)getRegisterByteByOffset:(uint32_t)address
{
    return [self getRegisterAtOffset:address] & 0xFF;
}

-(uint32_t)getRegisterAtOffset:(uint32_t)address
{
    switch(address)
    {
        case 0x0:
            return _registers->MEMCON1;
            break;
        case 0x2:
            return _registers->MEMCON2;
            break;
        case 0x4:
            return _registers->HC;
            break;
        case 0x6:
            return _registers->VC;
            break;
        case 0x8:
            return _registers->LPH;
            break;
        case 0xA:
            return _registers->LPV;
            break;
        case 0x10:
            return _registers->OB0;
            break;
        case 0x12:
            return _registers->OB1;
            break;
        case 0x14:
            return _registers->OB2;
            break;
        case 0x16:
            return _registers->OB3;
            break;
        case 0x20:
            return _registers->OLP;
            break;
        case 0x26:
            return _registers->OBF;
            break;
        case 0x28:
            return _registers->VMODE;
            break;
        case 0x2A:
            return _registers->BORD1;
            break;
        case 0x2C:
            return _registers->BORD2;
            break;
        case 0x2E:
            return _registers->HP;
            break;
        case 0x30:
            return _registers->HBB;
            break;
        case 0x32:
            return _registers->HBE;
            break;
        case 0x34:
            return _registers->HS;
            break;
        case 0x36:
            return _registers->HVS;
            break;
        case 0x38:
            return _registers->HDB1;
            break;
        case 0x3A:
            return _registers->HDB2;
            break;
        case 0x3C:
            return _registers->HDE;
            break;
        case 0x3E:
            return _registers->VP;
            break;
        case 0x40:
            return _registers->VBB;
            break;
        case 0x42:
            return _registers->VBE;
            break;
        case 0x44:
            return _registers->VS;
            break;
        case 0x46:
            return _registers->VDB;
            break;
        case 0x48:
            return _registers->VDE;
            break;
        case 0x4A:
            return _registers->VEB;
            break;
        case 0x4C:
            return _registers->VEE;
            break;
        case 0x4E:
            return _registers->VI;
            break;
        case 0x50:
            return _registers->PIT0;
            break;
        case 0x52:
            return _registers->PIT1;
            break;
        case 0x54:
            return _registers->HEQ;
            break;
        case 0x58:
            return _registers->BG;
            break;
        case 0xE0:
            return _registers->INTERRUPTS_WAITING;
            break;
        case 0xE2:
            return _registers->INT2;
            break;
        default:
            return 0x0;
    }
}

-(void)putRegisterAtOffset:(uint32_t)address value:(uint32_t)value size:(int)size
{
    uint16_t register_offset = 0;
    uint32_t write_value = 0;
    
    if(size == 4)
    {
        // Break into two word writes to handle adjacent registers.
        // Unaligned writes should fail with a bus error.
        [self putRegisterAtOffset:address+0 value:(value & 0xFFFF0000)>>16 size:2];
        [self putRegisterAtOffset:address+2 value:(value & 0x0000FFFF) size:2];
    }
    if(size == 2)
    {
        register_offset = address;
        write_value = value;
    }
    else if(size == 1)
    {
        if(address & 0x01)
        {
            // Unaligned: Get the high byte from the current register value and update the low byte.
            register_offset = address & 0xFE;
            write_value = ([self getRegisterAtOffset:register_offset] & 0xFF00) | (value & 0xFF);
        }
        else
        {
            // Aligned: Get the low byte from the current register value and update the high byte.
            register_offset = address;
            write_value = (value << 8) | ([self getRegisterAtOffset:address] & 0x00FF);
        }
    }
    
    switch(register_offset)
    {
        case 0x0:
            _registers->MEMCON1 = write_value;
            break;
        case 0x2:
             _registers->MEMCON2 = write_value;
            break;
        case 0x4:
             _registers->HC = write_value;
            break;
        case 0x6:
             _registers->VC = write_value;
            break;
        case 0x8:
             _registers->LPH = write_value;
            break;
        case 0xA:
             _registers->LPV = write_value;
            break;
        case 0x10:
            _registers->OB0 = write_value;
            break;
        case 0x12:
            _registers->OB1 = write_value;
            break;
        case 0x14:
            _registers->OB2 = write_value;
            break;
        case 0x16:
            _registers->OB3 = write_value;
            break;
        case 0x20:
            // High word of OLP
            _registers->OLP = (write_value << 16) | (_registers->OLP & 0x0000FFFF);
            break;
        case 0x22:
            // Low word of OLP
            _registers->OLP = (_registers->OLP & 0xFFFF0000) | write_value;
            break;
        case 0x26:
            _registers->OBF = write_value;
            break;
        case 0x28:
            _registers->VMODE = write_value;
            break;
        case 0x2A:
             _registers->BORD1 = write_value;
            break;
        case 0x2C:
             _registers->BORD2 = write_value;
            break;
        case 0x2E:
             _registers->HP = write_value;
            break;
        case 0x30:
             _registers->HBB = write_value;
            break;
        case 0x32:
             _registers->HBE = write_value;
            break;
        case 0x34:
             _registers->HS = write_value;
            break;
        case 0x36:
             _registers->HVS = write_value;
            break;
        case 0x38:
             _registers->HDB1 = write_value;
            break;
        case 0x3A:
             _registers->HDB2 = write_value;
            break;
        case 0x3C:
             _registers->HDE = write_value;
            break;
        case 0x3E:
             _registers->VP = write_value;
            break;
        case 0x40:
             _registers->VBB = write_value;
            break;
        case 0x42:
             _registers->VBE = write_value;
            break;
        case 0x44:
             _registers->VS = write_value;
            break;
        case 0x46:
             _registers->VDB = write_value;
            break;
        case 0x48:
             _registers->VDE = write_value;
            break;
        case 0x4A:
             _registers->VEB = write_value;
            break;
        case 0x4C:
             _registers->VEE = write_value;
            break;
        case 0x4E:
             _registers->VI = write_value;
            break;
        case 0x50:
             _registers->PIT0 = write_value;
            break;
        case 0x52:
             _registers->PIT1 = write_value;
            break;
        case 0x54:
             _registers->HEQ = write_value;
            break;
        case 0x58:
             _registers->BG = write_value;
            break;
        case 0xE0:
            // Special: INT1
            write_value = write_value & 0x1F1F;
            if(write_value & 0x1F00)
            {
                // Clear interrupt waiting flags
                _registers->INTERRUPTS_WAITING = (write_value & ~0x1F) & 0x1F;
            }
            else
            {
                // Set interrupt enabled flags
                _registers->INTERRUPTS_ENABLED = write_value & 0x1F;
            }
            break;
        case 0xE2:
             _registers->INT2 = write_value;
            break;
        default:
            break;
    }
}

@end
