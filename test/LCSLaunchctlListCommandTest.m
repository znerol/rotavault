//
//  LCSLaunchctlListCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>
#import "OCMockObject+NSTask.h"
#import "LCSExternalCommand+MockableTask.h"
#import "LCSLaunchctlListCommand.h"
#import "LCSCommandController.h"

@interface LCSLaunchctlListCommandTest : GHTestCase
@end

@implementation LCSLaunchctlListCommandTest
-(void)testLaunchctlListCommand
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertTrue([cmd.result isKindOfClass:[NSArray class]], @"Result must be an array");
}

-(void)testLaunchctlListCommandHeaderOnly
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    
    /* launchctl task */
    NSData *stdoutData = [@"PID\tStatus\tLabel\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished exit state");
    GHAssertEqualObjects(cmd.result, [NSArray array], @"Expecting an empty array");
}

-(void)testLaunchctlListCommandOneRunningJob
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    
    /* launchctl task */
    NSData *stdoutData = [@"PID\tStatus\tLabel\n123\t-\ttestjob\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished exit state");
    
    NSArray *expect = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                @"testjob", @"Label",
                                                [NSNumber numberWithInt:123], @"PID",
                                                nil]];
                                                
    GHAssertEqualObjects(cmd.result, expect, @"Expecting an empty array");
}

-(void)testLaunchctlListCommandOneJobWithNonZeroExitStatus
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    
    /* launchctl task */
    NSData *stdoutData = [@"PID\tStatus\tLabel\n-\t1\ttestjob\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished exit state");
    
    NSArray *expect = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                @"testjob", @"Label",
                                                [NSNumber numberWithInt:1], @"Status",
                                                nil]];
    
    GHAssertEqualObjects(cmd.result, expect, @"Expecting an empty array");
}

-(void)testLaunchctlListCommandOneJobTerminatedBySignal
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    
    /* launchctl task */
    NSData *stdoutData = [@"PID\tStatus\tLabel\n-\t-9\ttestjob\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished exit state");
    
    NSArray *expect = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                @"testjob", @"Label",
                                                [NSNumber numberWithInt:9], @"Signal",
                                                nil]];
    
    GHAssertEqualObjects(cmd.result, expect, @"Expecting an empty array");
}

-(void)testLaunchctlListCommandUnexpectedHeader
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    
    /* launchctl task */
    NSData *stdoutData = [@"Standard Output Test" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFailed, @"Expecting failed command state");
    GHAssertTrue([cmd.error isKindOfClass:[NSError class]], @"Expecting an error");
}
@end
