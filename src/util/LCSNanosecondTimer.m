//
//  LCSNanosecondTimer.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#include <mach/mach.h>
#include <mach/mach_time.h>
#import "LCSNanosecondTimer.h"

/* 
 * Technical Q&A QA1398
 * Mach Absolute Time Units
 * http://developer.apple.com/mac/library/qa/qa2004/qa1398.html
 */

@implementation LCSNanosecondTimer
-(void)setReferenceTime
{
    reference = mach_absolute_time();
}

-(long double)nanosecondsSinceReferenceTime
{
    return UInt64ToLongDouble(UnsignedWideToUInt64(AbsoluteToNanoseconds(UInt64ToUnsignedWide(mach_absolute_time() - reference))));
}

@end
