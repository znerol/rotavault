//
//  LCSLaunchctlListCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlListCommandTest.h"


@implementation LCSLaunchctlListCommandTest
-(void)setUp
{
    mgr = [[LCSCommandManager alloc] init];
    cmd = [[LCSLaunchctlListCommand alloc] init];
    ctl = [[LCSCommandController controllerWithCommand:cmd] retain];
    
    [mgr addCommandController:ctl];
}

-(void)tearDown
{
    [ctl release];
    ctl = nil;
    [cmd release];
    cmd = nil;
    [mgr release];
    mgr = nil;
}

-(void)testLaunchctlListCommand
{
    [ctl start];
    
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertTrue([ctl.result isKindOfClass:[NSArray class]], @"Result must be an array");
}
@end
