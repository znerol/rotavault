//
//  LCSLaunchctlInfoTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSLaunchctlInfoCommand.h"
#import "LCSCommandController.h"
#import "LCSCommandManager.h"
#import "LCSTestdir.h"


@interface LCSLaunchctlInfoCommandTest : GHTestCase
@end


@implementation LCSLaunchctlInfoCommandTest
-(void)testLaunchctlInfoCommand
{
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    
    NSTask *submitTask = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl"
                                                  arguments:[NSArray arrayWithObjects:@"submit", @"-l", label,
                                                             @"/bin/sleep", @"10", nil]];
    [submitTask waitUntilExit];
    
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSLaunchctlInfoCommand *cmd = [LCSLaunchctlInfoCommand commandWithLabel:label];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [mgr addCommandController:ctl];
    [ctl start];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
    GHAssertTrue([ctl.result isKindOfClass:[NSDictionary class]], @"Expecting a dictionary in the result");
    GHAssertEqualObjects([ctl.result objectForKey:@"Label"], label, @"Expecting matching job label");

    NSTask *removeTask = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl"
                                                  arguments:[NSArray arrayWithObjects:@"remove", label, nil]];
    [removeTask waitUntilExit];
    
    [mgr release];
}

-(void)testLaunchctlInfoNonExistingLabel
{
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob-not-existing.%0X", random()];
    
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSLaunchctlInfoCommand *cmd = [LCSLaunchctlInfoCommand commandWithLabel:label];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [mgr addCommandController:ctl];
    [ctl start];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFailed, @"Expecting LCSCommandStateFailed");
    
    [mgr release];
}
@end
