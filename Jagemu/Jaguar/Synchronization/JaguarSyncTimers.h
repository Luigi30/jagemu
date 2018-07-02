//
//  JaguarSyncTimers.h
//  Jagemu
//
//  Created by Kate on 7/1/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncTimer.h"

/* Emulation events. */
@interface JaguarSyncTimers : NSObject

@property NSMutableArray *timers;

-(instancetype)init;

/* Add a SyncTimer to the timers array. */
-(void)addTimer:(SyncTimer *)timer;

/* Get the timer that will expire soonest. */
-(SyncTimer *)getNextTimer;

/* Return the microseconds until the next timer expires. */
-(double)microsecondsToNextTimerExpiration;

// A number of microseconds have elapsed. Subtract it from all timers.
-(void)elapsed:(double)microseconds;

// Advance the system to the next event.
-(void)performNextTimer;

@end
