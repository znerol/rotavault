//
//  LCSLaunchctlRemoveTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSLaunchctlRemoveCommand.h"
#import "LCSCommandController.h"
#import "LCSCommandManager.h"
#import "LCSTestdir.h"


@interface LCSLaunchctlRemoveCommandTest : GHTestCase
@end


@implementation LCSLaunchctlRemoveCommandTest
-(void)testLaunchctlRemoveCommand
{
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    
    NSTask *submitTask = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl"
                                                  arguments:[NSArray arrayWithObjects:@"submit", @"-l", label,
                                                             @"/bin/sleep", @"10", nil]];
    [submitTask waitUntilExit];
    
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSLaunchctlRemoveCommand *cmd = [LCSLaunchctlRemoveCommand commandWithLabel:label];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    
    [mgr addCommandController:ctl];
    [ctl start];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
    
    [mgr release];
}

-(void)testLaunchctlRemoveNonExistingLabel
{
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob-not-existing.%0X", random()];
    
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSLaunchctlRemoveCommand *cmd = [LCSLaunchctlRemoveCommand commandWithLabel:label];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [mgr addCommandController:ctl];
    [ctl start];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFailed, @"Expecting LCSCommandStateFailed");
    
    [mgr release];
}
@end
