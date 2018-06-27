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

#endif /* memory_h */
