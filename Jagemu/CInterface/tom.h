//
//  tom.h
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#ifndef tom_h
#define tom_h

#include <stdio.h>

typedef uint32_t LineBuffer[360];



struct tom_state {
    struct tom_registers *registers;
};

#endif /* tom_h */
