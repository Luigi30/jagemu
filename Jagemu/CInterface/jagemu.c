//
//  jagemu.c
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#ifndef JAGEMU_H
#define JAGEMU_H

#include <stdio.h>
#include "jagemu.h"

/* Musashi functions */

/* TODO: actual address map */

/* CPU reads */
unsigned int cpu_read_byte(unsigned int address)
{
    if(address < 0x400000)
    {
        return jaguar_ram_area[address & 0x1FFFFF];
    }
    else return 0;
}

unsigned int cpu_read_word(unsigned int address)
{
    if(address < 0x400000)
    {
        return (jaguar_ram_area[address & 0x1FFFFF] << 8) | (jaguar_ram_area[address+1 & 0x1FFFFF]);
    }
    else return 0;
}

unsigned int cpu_read_long(unsigned int address)
{
    if(address < 0x400000)
    {
        return (jaguar_ram_area[address & 0x1FFFFF] << 24) |
        (jaguar_ram_area[address+1 & 0x1FFFFF] << 16) |
        (jaguar_ram_area[address+2 & 0x1FFFFF] << 8) |
        (jaguar_ram_area[address+3 & 0x1FFFFF]);
    }
    else return 0;
}

unsigned int cpu_read_word_dasm(unsigned int address)
{
    return 0;
}

unsigned int cpu_read_long_dasm(unsigned int address)
{
    return 0;
}

/* CPU writes */
void cpu_write_byte(unsigned int address, unsigned int value)
{
    
}

void cpu_write_word(unsigned int address, unsigned int value)
{
    
}

void cpu_write_long(unsigned int address, unsigned int value)
{
    
}

void cpu_write_long_pd(unsigned int address, unsigned int value)
{
    
}


int cpu_irq_ack(int level)
{
    return 0; // TODO
}

/* Reset callback. */
void cpu_pulse_reset(void)
{
    
}

/* Called before each instruction, if configured so. */
void cpu_instr_callback(void)
{
    // TODO
}

uint8_t fc;
void cpu_set_fc(unsigned int fcv)
{
    fc = fcv;
}

#endif
