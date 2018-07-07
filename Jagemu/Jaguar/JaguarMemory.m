//
//  JaguarMemory.m
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarMemory.h"

#import "m68k.h"

@implementation JaguarMemory

- (instancetype) init
{
    self = [super init];
    
    _WorkRAM = calloc(WORKRAM_SIZE, 1);
    _CartROM = calloc(CARTROM_SIZE, 1);
    _BootROM = calloc(BOOTROM_SIZE, 1);
    
    return self;
}

- (void)loadBootROM:(NSString *)path
{
    // Read the file at path and load it into BootROM.
    NSData *data = [NSData dataWithContentsOfFile: path];
    NSUInteger length = [data length];
    memcpy(_BootROM, [data bytes], length);
}

#define TOSPRG_HEADER 0x601A
- (void)loadJaguarServerExecutable:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile: path];
    NSUInteger length = [data length];
    uint8_t *rom = (uint8_t *)data.bytes;
    
    // Jaguar Server files are TOS .PRG files.
    if(((rom[0] << 8) | rom[1]) != TOSPRG_HEADER)
    {
        printf("Not a TOS PRG file\n");
        return;
    }
    
    // Check for the Jaguar Server header.
    uint32_t header = (rom[0x1F] << 24) | (rom[0x1E] << 16) | (rom[0x1D] << 8) | (rom[0x1C] << 0);
    if(header != ('J' | 'A' << 8 | 'G' << 16 | 'R' << 24))
    {
        printf("Not a Jaguar Server executable\n");
        return;
    }
    
    // Grab the download address...
    uint32_t download_address = rom[0x25] << 0 | rom[0x24] << 8 | rom[0x23] << 16 | rom[0x22] << 24;
    //uint32_t program_length = rom[0x29] << 0 | rom[0x28] << 8 | rom[0x27] << 16 | rom[0x26] << 24;
    uint32_t entry_point = rom[0x2D] << 0 | rom[0x2C] << 8 | rom[0x2B] << 16 | rom[0x2A] << 24;
    
    memcpy(_WorkRAM+download_address, rom+0x2E, length-46);
    m68k_set_reg(M68K_REG_PC, entry_point);
}

@end
