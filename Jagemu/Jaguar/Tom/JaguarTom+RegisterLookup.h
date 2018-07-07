//
//  JaguarTom+RegisterLookup.h
//  Jagemu
//
//  Created by Kate on 7/6/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarTom.h"

@interface JaguarTom (RegisterLookup)

// Register functions
-(uint32_t)getRegisterLongByOffset:(uint32_t)address;
-(uint16_t)getRegisterWordByOffset:(uint32_t)address;
-(uint8_t)getRegisterByteByOffset:(uint32_t)address;

-(void)putRegisterAtOffset:(uint32_t)address value:(uint32_t)value;

-(uint16_t)getClutWordByOffset:(uint32_t)offset;
-(void)putClutWordByOffset:(uint32_t)offset value:(uint16_t)value;

@end
