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

-(void)putRegisterAtOffset:(uint32_t)address value:(uint32_t)value size:(int)size;

-(uint8_t)getClutByteByOffset:(uint32_t)offset;
-(uint16_t)getClutWordByOffset:(uint32_t)offset;
-(uint32_t)getClutLongByOffset:(uint32_t)offset;

-(void)putClutByteByOffset:(uint32_t)offset value:(uint8_t)value;
-(void)putClutWordByOffset:(uint32_t)offset value:(uint16_t)value;
-(void)putClutLongByOffset:(uint32_t)offset value:(uint32_t)value;

@end
