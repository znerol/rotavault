//
//  LCSLaunchctlInfoTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSLaunchctlInfoCommand.h"
#import "LCSCommand.h"
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
    
    LCSLaunchctlInfoCommand *cmd = [LCSLaunchctlInfoCommand commandWithLabel:label];
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
    GHAssertTrue([cmd.result isKindOfClass:[NSDictionary class]], @"Expecting a dictionary in the result");
    GHAssertEqualObjects([cmd.result objectForKey:@"Label"], label, @"Expecting matching job label");

    NSTask *removeTask = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl"
                                                  arguments:[NSArray arrayWithObjects:@"remove", label, nil]];
    [removeTask waitUntilExit];
}

-(void)testLaunchctlInfoNonExistingLabel
{
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob-not-existing.%0X", random()];
    
    LCSLaunchctlInfoCommand *cmd = [LCSLaunchctlInfoCommand commandWithLabel:label];
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFailed, @"Expecting LCSCommandStateFailed");
}
@end
