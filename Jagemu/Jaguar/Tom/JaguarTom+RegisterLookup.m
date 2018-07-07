//
//  JaguarTom+RegisterLookup.m
//  Jagemu
//
//  Created by Kate on 7/6/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarTom+RegisterLookup.h"

@implementation JaguarTom (RegisterLookup)

-(uint16_t)getClutWordByOffset:(uint32_t)offset
{
    return _registers->CLUT[offset];
}

-(void)putClutWordByOffset:(uint32_t)offset value:(uint16_t)value
{
    _registers->CLUT[offset] = value;
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
            return _registers->INT1;
            break;
        case 0xE2:
            return _registers->INT2;
            break;
        default:
            return 0x0;
    }
}

-(void)putRegisterAtOffset:(uint32_t)address value:(uint32_t)value
{
    switch(address)
    {
        case 0x0:
            _registers->MEMCON1 = value;
            break;
        case 0x2:
             _registers->MEMCON2 = value;
            break;
        case 0x4:
             _registers->HC = value;
            break;
        case 0x6:
             _registers->VC = value;
            break;
        case 0x8:
             _registers->LPH = value;
            break;
        case 0xA:
             _registers->LPV = value;
            break;
        case 0x10:
            _registers->OB0 = value;
            break;
        case 0x12:
             _registers->OB1 = value;
            break;
        case 0x14:
             _registers->OB2 = value;
            break;
        case 0x16:
             _registers->OB3 = value;
            break;
        case 0x20:
             _registers->OLP = value;
            break;
        case 0x26:
             _registers->OBF = value;
            break;
        case 0x28:
             _registers->VMODE = value;
            break;
        case 0x2A:
             _registers->BORD1 = value;
            break;
        case 0x2C:
             _registers->BORD2 = value;
            break;
        case 0x2E:
             _registers->HP = value;
            break;
        case 0x30:
             _registers->HBB = value;
            break;
        case 0x32:
             _registers->HBE = value;
            break;
        case 0x34:
             _registers->HS = value;
            break;
        case 0x36:
             _registers->HVS = value;
            break;
        case 0x38:
             _registers->HDB1 = value;
            break;
        case 0x3A:
             _registers->HDB2 = value;
            break;
        case 0x3C:
             _registers->HDE = value;
            break;
        case 0x3E:
             _registers->VP = value;
            break;
        case 0x40:
             _registers->VBB = value;
            break;
        case 0x42:
             _registers->VBE = value;
            break;
        case 0x44:
             _registers->VS = value;
            break;
        case 0x46:
             _registers->VDB = value;
            break;
        case 0x48:
             _registers->VDE = value;
            break;
        case 0x4A:
             _registers->VEB = value;
            break;
        case 0x4C:
             _registers->VEE = value;
            break;
        case 0x4E:
             _registers->VI = value;
            break;
        case 0x50:
             _registers->PIT0 = value;
            break;
        case 0x52:
             _registers->PIT1 = value;
            break;
        case 0x54:
             _registers->HEQ = value;
            break;
        case 0x58:
             _registers->BG = value;
            break;
        case 0xE0:
             _registers->INT1 = value;
            break;
        case 0xE2:
             _registers->INT2 = value;
            break;
        default:
            break;
    }
}

@end
