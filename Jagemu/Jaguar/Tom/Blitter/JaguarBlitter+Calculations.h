//
//  JaguarBlitter+Calculations.h
//  Jagemu
//
//  Created by Kate on 7/16/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarBlitter.h"

@interface JaguarBlitter (Calculations)

-(void)populateA1Flags:(struct blitter_a1_flags_t *)flags;
-(uint32_t)getWindowWidth:(uint8_t)fp_value;

@end
