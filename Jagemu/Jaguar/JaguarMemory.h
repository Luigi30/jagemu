//
//  JaguarMemory.h
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WORKRAM_SIZE 0x200000
#define CARTROM_SIZE 0x600000
#define BOOTROM_SIZE 0x20000

@interface JaguarMemory : NSObject
{
    /* 0x200000 (2MB) of RAM at 0x000000. Shadowed at 0x200000. */
    uint8_t *_WorkRAM;
    
    /* 0x600000 (6MB) of ROM space at 0x800000. */
    uint8_t *_CartROM;
    
    /* 0x020000 (128K) of boot ROM at 0xE00000 */
    uint8_t *_BootROM;
}

@property uint8_t *WorkRAM;
@property uint8_t *CartROM;
@property uint8_t *BootROM;

- (instancetype)init;

/* Reads in a binary file and loads it into BootROM. */
- (void)loadBootROM:(NSString *)path;

@end
