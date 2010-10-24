//
//  LCSBatchCommandUnitTest.m
//  rotavault
//
//  Created by Lorenz Schori on 24.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSBatchCommand.h"
#import "LCSTestCommand.h"

@interface LCSTestBatchCommand : LCSBatchCommand
@property(readonly) LCSCommandCollection* activeCommands;
@end

@implementation LCSTestBatchCommand
- (void)performStart
{
    self.state = LCSCommandStateRunning;
    
    for (LCSCommand* cmd in activeCommands.commands) {
        [cmd start];
    }
}

- (LCSCommandCollection*)activeCommands
{
    return activeCommands;
}
@end


@interface LCSBatchCommandUnitTest : GHTestCase
@end

@implementation LCSBatchCommandUnitTest
- (void)testOneSingleFailingCommand
{
    LCSTestCommand *testcmd = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFailed];
    LCSTestBatchCommand *batchcmd = [[[LCSTestBatchCommand alloc] init] autorelease];
    
    [batchcmd.activeCommands addCommand:testcmd];
    [batchcmd start];
    [batchcmd waitUntilDone];
    
    GHAssertEquals(batchcmd.exitState, LCSCommandStateFailed, @"Expected LCSCommandStateFailed");
}

- (void)testOneFailingOneSuccessfulCommand
{
    LCSTestCommand *testcmd1 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSTestCommand *testcmd2 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFailed];
    LCSTestBatchCommand *batchcmd = [[[LCSTestBatchCommand alloc] init] autorelease];
    
    [batchcmd.activeCommands addCommand:testcmd1];
    [batchcmd.activeCommands addCommand:testcmd2];
    [batchcmd start];
    [batchcmd waitUntilDone];
    
    GHAssertEquals(batchcmd.exitState, LCSCommandStateFailed, @"Expected LCSCommandStateFailed");
}

- (void)testOneFailingOneCancelledCommand
{
    LCSTestCommand *testcmd1 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSTestCommand *testcmd2 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSTestBatchCommand *batchcmd = [[[LCSTestBatchCommand alloc] init] autorelease];
    
    [batchcmd.activeCommands addCommand:testcmd1];
    [batchcmd.activeCommands addCommand:testcmd2];
    [batchcmd start];
    [testcmd1 cancel];
    [batchcmd waitUntilDone];
    
    GHAssertEquals(batchcmd.exitState, LCSCommandStateFailed, @"Expected LCSCommandStateFailed");
}
@end

