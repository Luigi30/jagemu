//
//  JaguarDefines.h
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#ifndef JaguarDefines_h
#define JaguarDefines_h

// Video output is interlaced, so effectively 60fps.
#define FRAMES_PER_SECOND 60
#define LINES_PER_FRAME 525

/* Clocks */
#define CLOCK_NTSC      26590906
#define CLOCK_PAL       26593900
#define CLOCK_MASTER    CLOCK_NTSC

#define CLOCK_M68K      (CLOCK_MASTER/2)    // Runs at 1/2 the master clock speed
#define CLOCK_RISC      (CLOCK_NTSC)        // Runs at the master clock speed

#define VIDEO_CLOCKS_PER_FRAME  (CLOCK_MASTER / FRAMES_PER_SECOND)
#define RISC_CLOCKS_PER_FRAME   (CLOCK_MASTER / FRAMES_PER_SECOND)
#define CPU_CLOCKS_PER_FRAME    (CLOCK_M68K / FRAMES_PER_SECOND)

#define VIDEO_CLOCKS_PER_LINE   (VIDEO_CLOCKS_PER_FRAME / LINES_PER_FRAME)
#define RISC_CLOCKS_PER_LINE    (RISC_CLOCKS_PER_FRAME / LINES_PER_FRAME)
#define CPU_CLOCKS_PER_LINE     (CPU_CLOCKS_PER_FRAME / LINES_PER_FRAME)

#endif /* JaguarDefines_h */