//
//  SyncTimer.m
//  Jagemu
//
//  Created by Kate on 7/1/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "SyncTimer.h"
#import "JaguarSystem.h"

@implementation SyncTimer

-(instancetype)initWithMicroseconds:(double)uS_to_fire
                          repeating:(Boolean)repeating
                         timer_type:(TIMER_TYPE)timer_type
                             source:(TIMER_DEVICE)source
                        destination:(TIMER_DEVICE)destination
                           callback:(SEL)callback_func
{
    self = [super init];

    self.initialized_uS = uS_to_fire;
    self.uS_to_fire = uS_to_fire;
    self.repeating = repeating;
    self.timer_type = timer_type;
    self.source = source;
    self.destination = destination;
    self.callback_selector = callback_func;

    return self;
}

-(void)performTimerCallback
{
    JaguarSystem *jaguar = JaguarSystem.sharedJaguar;
    
    IMP imp = [jaguar methodForSelector:_callback_selector];
    void (*func)(id, SEL) = (void *)imp;

    func(jaguar, _callback_selector);
}

@end
