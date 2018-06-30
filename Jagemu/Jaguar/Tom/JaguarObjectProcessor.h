//
//  JaguarObjectProcessor.h
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JaguarObjectProcessor : NSObject
{
    struct tom_registers_t *_registers;
}

@property struct tom_registers_t *registers;

-(instancetype)init:(struct tom_registers_t *)registers;

@end
