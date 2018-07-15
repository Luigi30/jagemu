//
//  AddressMap.h
//  Jagemu
//
//  Created by Kate on 7/14/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressMapEntry : NSObject

@property uint32_t start;
@property uint32_t end;

-(instancetype)initWithStart:(uint32_t)start end:(uint32_t)end;

@end

@interface AddressMap : NSObject

@property NSArray *entries;

-(instancetype)init;

@end
