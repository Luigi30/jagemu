//
//  JaguarObjectProcessor.h
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

/* The Jaguar object processor.
 *
 * See the Software Reference manual (chapter 3 of the Jaguar developer manuals)
 * for details on the objects and their structures.
 *
 * The object processor's job is to traverse a linked list of graphics objects,
 * determine which ones are to be drawn on this scanline, and draw them to the
 * line buffer if required.
 *
 * The object processor deals in terms of 64-bit phrases.
 *
 * There are five types of objects:
 * - 0: BITMAP - 2 phrases - aligned on a 2-phrase boundary.
 *      Display a bitmap object.
 *
 * - 1: SCALE  - 3 phrases - aligned on a 4-phrase boundary.
 *      Display a scaled bitmap object.
 *
 * - 2: GPU    - 1 phrase  - aligned on a 1-phrase boundary
 *      Triggers a GPU interrupt.
 *
 * - 3: BRANCH - 1 phrase  - aligned on a 1-phrase boundary
 *      Causes the object processor to branch to another point in the list
 *      if a condition code is true.
 *
 * - 4: STOP   - 1 phrase  - aligned on a 1-phrase boundary
 *      Terminates the object list and stops the object processor immediately.
 *      Optionally interrupts the CPU.
 *
 */

#import <Foundation/Foundation.h>

#import "JaguarOPObject.h"
#import "JaguarDefines.h"

@interface JaguarObjectProcessor : NSObject
{
    struct tom_registers_t *_registers;
}

@property struct tom_registers_t *registers;

-(instancetype)init:(struct tom_registers_t *)registers;
-(void)executeHalfLine;

-(JaguarOPObject *) parseOPObject:(uint8_t *)op_object;

-(uint32_t)performBitmapObject:(JaguarOPObjectBitmap *)op_object currentOP:(uint32_t)current;
-(uint32_t)performScaledObject:(JaguarOPObjectScaled *)op_object currentOP:(uint32_t)current;
-(uint32_t)performGPUObject:(JaguarOPObjectGPU *)op_object currentOP:(uint32_t)current;
-(uint32_t)performBranchObject:(JaguarOPObjectBranch *)op_object currentOP:(uint32_t)current;
-(uint32_t)performStopObject:(JaguarOPObjectStop *)op_object currentOP:(uint32_t)current;

@end
