//
//  jagemu.h
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#ifndef jagemu_h
#define jagemu_h

#include <stdint.h>
#include "memory.h"

extern uint8_t fc;

extern void cpu_set_fc(unsigned int fcv);

extern int cpu_irq_ack(int level);
extern void cpu_pulse_reset(void);
void cpu_instr_callback(void);

#endif /* jagemu_h */
