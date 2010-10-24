//
//  LCSLaunchctlRemoveTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSLaunchctlRemoveCommand.h"
#import "LCSCommand.h"
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
    
    LCSLaunchctlRemoveCommand *cmd = [LCSLaunchctlRemoveCommand commandWithLabel:label];
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
}

-(void)testLaunchctlRemoveNonExistingLabel
{
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob-not-existing.%0X", random()];
    
    LCSLaunchctlRemoveCommand *cmd = [LCSLaunchctlRemoveCommand commandWithLabel:label];
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFailed, @"Expecting LCSCommandStateFailed");
}
@end
