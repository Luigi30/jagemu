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

int cpu_irq_ack(int level)
{
    return 0; // TODO
}

/* Reset callback. */
void cpu_pulse_reset(void)
{
    // TODO
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
