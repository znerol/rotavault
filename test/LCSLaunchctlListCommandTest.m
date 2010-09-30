//
//  LCSLaunchctlListCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSCommandManager.h"
#import "LCSLaunchctlListCommand.h"
#import "LCSCommandController.h"


@interface LCSLaunchctlListCommandTest : GHTestCase
@end

@implementation LCSLaunchctlListCommandTest
-(void)testLaunchctlListCommand
{
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [mgr addCommandController:ctl];
    [ctl start];    
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertTrue([ctl.result isKindOfClass:[NSArray class]], @"Result must be an array");

    [mgr release];
}
@end
