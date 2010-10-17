//
//  NSNotificationCenter+DefaultCenterThreadLocal.m
//  test-cross-thread-notification
//
//  Created by Lorenz Schori on 17.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSNotificationCenter+DefaultCenterThreadLocal.h"

#define LCSThreadLocalDefaultNotificationCenterKey @"LCSThreadLocalDefaultNotificationCenter"

@implementation NSNotificationCenter (DefaultCenterThreadLocal)
+ (NSNotificationCenter*)defaultCenter
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSNotificationCenter *defaultThreadLocalCenter;
    
    defaultThreadLocalCenter = [threadDictionary objectForKey:LCSThreadLocalDefaultNotificationCenterKey];
    if (defaultThreadLocalCenter == nil) {
        defaultThreadLocalCenter = [[[NSNotificationCenter alloc] init] autorelease];
        [threadDictionary setObject:defaultThreadLocalCenter forKey:LCSThreadLocalDefaultNotificationCenterKey];
    }
    
    return defaultThreadLocalCenter;
}
@end
