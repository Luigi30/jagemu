//
//  JaguarBlitterFlags.h
//  Jagemu
//
//  Created by Kate on 7/16/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#ifndef JaguarBlitterFlags_h
#define JaguarBlitterFlags_h

enum blitter_pitch_t {
    PITCH1,
    PITCH2,
    PITCH3,
    PITCH4
};

enum blitter_pixel_size_t {
    PIXEL1,
    PIXEL2,
    PIXEL4,
    PIXEL8,
    PIXEL16,
    PIXEL32
};

enum blitter_z_offset_t {
    ZOFFS0,
    ZOFFS1,
    ZOFFS2,
    ZOFFS3,
    ZOFFS4,
    ZOFFS5,
    ZOFFS6,
    ZOFFS7
};

enum blitter_x_add_t {
    XADDPHR,
    XADDPIX,
    XADD0,
    XADDINC
};

enum blitter_y_add_t {
    YADD0,
    YADD1
};

struct blitter_a1_flags_t
{
    enum blitter_pitch_t pitch;
    enum blitter_pixel_size_t pixel_size;
    enum blitter_z_offset_t z_offset;
    uint16_t window_width;
    enum blitter_x_add_t x_add_ctrl;
    enum blitter_y_add_t y_add_ctrl;
    Boolean x_sign_sub;
    Boolean y_sign_sub;
};

#endif /* JaguarBlitterFlags_h */
