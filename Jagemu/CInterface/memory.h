//
//  memory.h
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#ifndef memory_h
#define memory_h

#include <stdio.h>

/* 0x200000 of RAM at 0x000000. Shadowed at 0x200000. */
extern uint8_t jaguar_ram_area[0x200000];

/* 0x600000 of ROM space at 0x800000. */
extern uint8_t jaguar_cart_rom[0x600000];

/* 128K of boot ROM at 0xE00000 */
extern uint8_t jaguar_boot_rom[0x20000];

extern unsigned int cpu_read_byte(unsigned int address);
extern unsigned int cpu_read_word(unsigned int address);
extern unsigned int cpu_read_long(unsigned int address);
extern unsigned int cpu_read_word_dasm(unsigned int address);
extern unsigned int cpu_read_long_dasm(unsigned int address);
extern void cpu_write_byte(unsigned int address, unsigned int value);
extern void cpu_write_word(unsigned int address, unsigned int value);
extern void cpu_write_long(unsigned int address, unsigned int value);
extern void cpu_write_long_pd(unsigned int address, unsigned int value);

// Debug: Wrote to ROM.
void wrote_to_rom(unsigned int address, unsigned int value);

#endif /* memory_h */
