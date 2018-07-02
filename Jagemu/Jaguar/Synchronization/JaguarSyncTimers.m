//
//  JaguarSyncTimers.m
//  Jagemu
//
//  Created by Kate on 7/1/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarSyncTimers.h"

@implementation JaguarSyncTimers

-(instancetype)init
{
    self = [super init];
    self.timers = [[NSMutableArray alloc] init];
    
    return self;
}

-(void)addTimer:(SyncTimer *)timer
{
    [self.timers addObject:timer];
}

-(SyncTimer *)getNextTimer
{
    SyncTimer *next;

    if(self.timers.count == 0)
    {
        return nil;
    }
    else
    {
        next = self.timers[0];
        
        for(int i=0; i<self.timers.count; i++)
        {
            SyncTimer *timer = self.timers[i];
            if(timer.uS_to_fire < next.uS_to_fire)
                next = timer;
        }
    }
    
    return next;
}

-(double)microsecondsToNextTimerExpiration
{
    SyncTimer *timer = [self getNextTimer];
    return timer.uS_to_fire;
}

-(void)elapsed:(double)microseconds
{
    for(int i=0; i<self.timers.count; i++)
    {
        ((SyncTimer *)self.timers[i]).uS_to_fire -= microseconds;
    }
}

-(void)performNextTimer
{
    //[[self Timers] elapsed:timer.uS_to_fire];
    
    // Get the period to advance the system timing.
    double microseconds_elapsed = [self microsecondsToNextTimerExpiration];
    
    // Advance all timers.
    [self elapsed:microseconds_elapsed];
    
    // Find the next event.
    SyncTimer *next =[self getNextTimer];

    if(next.repeating)
    {
        // Reset if it's a repeating timer.
        next.uS_to_fire = next.initialized_uS;
    }
    
    //Execute the callback.
    [next performTimerCallback];
}

@end
