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

extern unsigned int cpu_read_byte(unsigned int address);
extern unsigned int cpu_read_word(unsigned int address);
extern unsigned int cpu_read_long(unsigned int address);
extern unsigned int cpu_read_word_dasm(unsigned int address);
extern unsigned int cpu_read_long_dasm(unsigned int address);
extern void cpu_write_byte(unsigned int address, unsigned int value);
extern void cpu_write_word(unsigned int address, unsigned int value);
extern void cpu_write_long(unsigned int address, unsigned int value);
extern void cpu_write_long_pd(unsigned int address, unsigned int value);
extern int cpu_irq_ack(int level);
extern void cpu_pulse_reset(void);
void cpu_instr_callback(void);

#endif /* jagemu_h */
