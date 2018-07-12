//
//  JaguarTom+Render.h
//  Jagemu
//
//  Created by Kate on 7/11/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

#import "JaguarTom.h"

extern uint8_t redcv[16][16];
extern uint8_t greencv[16][16];
extern uint8_t bluecv[16][16];

@interface JaguarTom (Render)

-(void)fillColorLookupTables;

-(uint16_t)videoModePixelWidth;

-(void)renderLineCRY16:(uint32_t *)lineBuffer;

@end
