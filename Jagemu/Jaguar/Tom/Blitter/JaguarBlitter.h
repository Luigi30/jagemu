//
//  JaguarBlitter.h
//  Jagemu
//
//  Created by Kate on 7/14/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressMap.h"

struct blitter_registers_t;

@interface JaguarBlitter : NSObject
{
    struct blitter_registers_t *_registers;
}

@property struct blitter_registers_t *registers;

-(instancetype)init;

@end
