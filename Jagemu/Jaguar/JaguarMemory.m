//
//  JaguarMemory.m
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarMemory.h"

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

@end
