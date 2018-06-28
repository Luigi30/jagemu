//
//  memory.c
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#include "memory.h"

uint8_t jaguar_ram_area[0x200000];
uint8_t jaguar_cart_rom[0x600000];
uint8_t jaguar_boot_rom[0x20000];

/* CPU reads */
unsigned int cpu_read_byte(unsigned int address)
{
    if(address < 0x400000)
    {
        return jaguar_ram_area[address & 0x1FFFFF];
    }
    else if(address >= 0x800000 && address < 0xE00000)
        return jaguar_cart_rom[address];
    else if(address >= 0xE00000 && address < 0xE20000)
        return jaguar_boot_rom[address];
    else return 0;
}

unsigned int cpu_read_word(unsigned int address)
{
    if(address < 0x400000)
        return (jaguar_ram_area[address & 0x1FFFFF] << 8) | (jaguar_ram_area[address+1 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return (jaguar_cart_rom[address] << 8) | (jaguar_cart_rom[address+1]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return (jaguar_boot_rom[address] << 8) | (jaguar_boot_rom[address+1]);
    else return 0;
}

unsigned int cpu_read_long(unsigned int address)
{
    if(address < 0x400000)
        return (jaguar_ram_area[address & 0x1FFFFF] << 24) |
        (jaguar_ram_area[address+1 & 0x1FFFFF] << 16) |
        (jaguar_ram_area[address+2 & 0x1FFFFF] << 8) |
        (jaguar_ram_area[address+3 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return (jaguar_cart_rom[address] << 24) |
        (jaguar_cart_rom[address+1] << 16) |
        (jaguar_cart_rom[address+2] << 8) |
        (jaguar_cart_rom[address+3]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return (jaguar_boot_rom[address] << 24) |
        (jaguar_boot_rom[address+1] << 16) |
        (jaguar_boot_rom[address+2] << 8) |
        (jaguar_boot_rom[address+3]);
    else return 0;
}

unsigned int cpu_read_word_dasm(unsigned int address)
{
    if(address < 0x400000)
        return (jaguar_ram_area[address & 0x1FFFFF] << 8) | (jaguar_ram_area[address+1 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return (jaguar_cart_rom[address] << 8) | (jaguar_cart_rom[address+1]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return (jaguar_boot_rom[address] << 8) | (jaguar_boot_rom[address+1]);
    else return 0;
}

unsigned int cpu_read_long_dasm(unsigned int address)
{
    if(address < 0x400000)
        return (jaguar_ram_area[address & 0x1FFFFF] << 24) |
        (jaguar_ram_area[address+1 & 0x1FFFFF] << 16) |
        (jaguar_ram_area[address+2 & 0x1FFFFF] << 8) |
        (jaguar_ram_area[address+3 & 0x1FFFFF]);
    else if(address >= 0x800000 && address < 0xE00000)
        return (jaguar_cart_rom[address] << 24) |
        (jaguar_cart_rom[address+1] << 16) |
        (jaguar_cart_rom[address+2] << 8) |
        (jaguar_cart_rom[address+3]);
    else if(address >= 0xE00000 && address < 0xE20000)
        return (jaguar_boot_rom[address] << 24) |
        (jaguar_boot_rom[address+1] << 16) |
        (jaguar_boot_rom[address+2] << 8) |
        (jaguar_boot_rom[address+3]);
    else return 0;
}

/* CPU writes */
void cpu_write_byte(unsigned int address, unsigned int value)
{
    if(address < 0x400000)
    {
        jaguar_ram_area[address & 0x1FFFFF] = value;
    }
    else if(address >= 0x800000 && address < 0xE00000)
        wrote_to_rom(address, value);
    else if(address >= 0xE00000 && address < 0xE20000)
        wrote_to_rom(address, value);
}

void cpu_write_word(unsigned int address, unsigned int value)
{
    if(address < 0x400000)
    {
        jaguar_ram_area[address+0 & 0x1FFFFF] = value & 0xFF00;
        jaguar_ram_area[address+1 & 0x1FFFFF] = value & 0x00FF;
    }
    else if(address >= 0x800000 && address < 0xE00000)
        wrote_to_rom(address, value);
    else if(address >= 0xE00000 && address < 0xE20000)
        wrote_to_rom(address, value);
}

void cpu_write_long(unsigned int address, unsigned int value)
{
    if(address < 0x400000)
    {
        jaguar_ram_area[address+0 & 0x1FFFFF] = value & 0xFF000000;
        jaguar_ram_area[address+1 & 0x1FFFFF] = value & 0x00FF0000;
        jaguar_ram_area[address+2 & 0x1FFFFF] = value & 0x0000FF00;
        jaguar_ram_area[address+3 & 0x1FFFFF] = value & 0x000000FF;
    }
    else if(address >= 0x800000 && address < 0xE00000)
        wrote_to_rom(address, value);
    else if(address >= 0xE00000 && address < 0xE20000)
        wrote_to_rom(address, value);
}
/*
 * To simulate real 68k behavior, first write the high word to
 * [address+2], and then write the low word to [address].
 */
void cpu_write_long_pd(unsigned int address, unsigned int value)
{
    if(address < 0x400000)
    {
        jaguar_ram_area[address+2 & 0x1FFFFF] = value & 0xFF000000;
        jaguar_ram_area[address+3 & 0x1FFFFF] = value & 0x00FF0000;
        jaguar_ram_area[address+0 & 0x1FFFFF] = value & 0x0000FF00;
        jaguar_ram_area[address+1 & 0x1FFFFF] = value & 0x000000FF;
    }
    else if(address >= 0x800000 && address < 0xE00000)
        wrote_to_rom(address, value);
    else if(address >= 0xE00000 && address < 0xE20000)
        wrote_to_rom(address, value);
}

void wrote_to_rom(unsigned int address, unsigned int value)
{
    printf("Attempted write to ROM at %06X\n", address);
}
