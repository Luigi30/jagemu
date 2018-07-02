//
//  SyncTimer.h
//  Jagemu
//
//  Created by Kate on 7/1/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncTimer : NSObject

typedef enum timer_device_t {
    T_DEV_INTERNAL,
    T_DEV_CPU,
    T_DEV_GPU,
    T_DEV_DSP,
    T_DEV_OP
} TIMER_DEVICE;

typedef enum timer_type_t {
    T_TYPE_HALFLINE_END,
    T_TYPE_FRAME_END
} TIMER_TYPE;

@property double initialized_uS;    // how many uS was the timer initialized to?
@property double uS_to_fire;        // uS remaining in this timer
@property Boolean repeating;        // does this timer repeat (reset to initialized_uS when it expires)?
@property TIMER_TYPE timer_type;
@property TIMER_DEVICE source;
@property TIMER_DEVICE destination;
@property SEL callback_selector;    // the callback executed when this timer expires

-(instancetype)initWithMicroseconds:(double)uS_to_fire
                          repeating:(Boolean)repeating
                         timer_type:(TIMER_TYPE)timer_type
                             source:(TIMER_DEVICE)source
                        destination:(TIMER_DEVICE)destination
                           callback:(SEL)callback_func;

-(void)performTimerCallback;

@end
