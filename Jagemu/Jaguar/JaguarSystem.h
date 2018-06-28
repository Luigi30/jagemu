//
//  JaguarSystem.h
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JaguarMemory.h"
#import "JaguarTom.h"

@interface JaguarSystem : NSObject {
    JaguarMemory *_Memory;
    JaguarTom *_Tom;
}

@property JaguarTom *Tom;
@property JaguarMemory *Memory;

- (instancetype) init;

@end
