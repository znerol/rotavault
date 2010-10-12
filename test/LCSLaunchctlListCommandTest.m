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
#import "LCSLaunchctlListCommand.h"
#import "LCSCommandController.h"

@interface LCSExternalCommand (MutableTask)
@property(retain) NSTask* task;
@end

@implementation LCSExternalCommand (MutableTask)
-(void)setTask:(NSTask*)newTask
{
    if (task == newTask) {
        return;
    }
    
    [task release];
    task = [newTask retain];
}

-(NSTask*)task
{
    return task;
}
@end


@interface LCSLaunchctlListCommandTest : GHTestCase
@end

@implementation LCSLaunchctlListCommandTest
-(void)testLaunchctlListCommand
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [ctl start];
    [ctl waitUntilDone];
    
    GHAssertTrue([ctl.result isKindOfClass:[NSArray class]], @"Result must be an array");
}

-(void)testLaunchctlListCommandHeaderOnly
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    /* launchctl task */
    NSData *stdoutData = [@"PID\tStatus\tLabel\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [ctl start];
    [ctl waitUntilDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished exit state");
    GHAssertEqualObjects(ctl.result, [NSArray array], @"Expecting an empty array");
}

-(void)testLaunchctlListCommandOneRunningJob
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    /* launchctl task */
    NSData *stdoutData = [@"PID\tStatus\tLabel\n123\t-\ttestjob\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [ctl start];
    [ctl waitUntilDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished exit state");
    
    NSArray *expect = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                @"testjob", @"Label",
                                                [NSNumber numberWithInt:123], @"PID",
                                                nil]];
                                                
    GHAssertEqualObjects(ctl.result, expect, @"Expecting an empty array");
}

-(void)testLaunchctlListCommandOneJobWithNonZeroExitStatus
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    /* launchctl task */
    NSData *stdoutData = [@"PID\tStatus\tLabel\n-\t1\ttestjob\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [ctl start];
    [ctl waitUntilDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished exit state");
    
    NSArray *expect = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                @"testjob", @"Label",
                                                [NSNumber numberWithInt:1], @"Status",
                                                nil]];
    
    GHAssertEqualObjects(ctl.result, expect, @"Expecting an empty array");
}

-(void)testLaunchctlListCommandOneJobTerminatedBySignal
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    /* launchctl task */
    NSData *stdoutData = [@"PID\tStatus\tLabel\n-\t-9\ttestjob\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [ctl start];
    [ctl waitUntilDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished exit state");
    
    NSArray *expect = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                @"testjob", @"Label",
                                                [NSNumber numberWithInt:9], @"Signal",
                                                nil]];
    
    GHAssertEqualObjects(ctl.result, expect, @"Expecting an empty array");
}

-(void)testLaunchctlListCommandUnexpectedHeader
{
    LCSLaunchctlListCommand *cmd = [LCSLaunchctlListCommand command];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    /* launchctl task */
    NSData *stdoutData = [@"Standard Output Test" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    
    id mockTask = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:stdoutData stderrData:stderrData];
    cmd.task = mockTask;
    
    [ctl start];
    [ctl waitUntilDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFailed, @"Expecting failed command state");
    GHAssertTrue([ctl.error isKindOfClass:[NSError class]], @"Expecting an error");
}
@end
