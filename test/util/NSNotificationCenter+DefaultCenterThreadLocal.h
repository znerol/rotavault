//
//  NSNotificationCenter+DefaultCenterThreadLocal.h
//  test-cross-thread-notification
//
//  Created by Lorenz Schori on 17.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSNotificationCenter (DefaultCenterThreadLocal)
+ (NSNotificationCenter*)defaultCenter;
@end
