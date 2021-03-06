//
//  LCSMockedAppleRAIDListCommandUnitTest.m
//  rotavault
//
//  Created by Lorenz Schori on 17.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//


#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>
#import "LCSAppleRAIDListCommand.h"
#import "OCMockObject+NSTask.h"
#import "LCSExternalCommand.h"
#import "LCSExternalCommand+MockableTask.h"
#import "LCSCommand.h"

@interface LCSMockedAppleRAIDListCommandUnitTest : GHTestCase
{
    NSEnumerator* taskFixtureEnumerator;
    NSMutableArray* taskMocks;
}
@end

@implementation LCSMockedAppleRAIDListCommandUnitTest
-(void) testList
{
    LCSAppleRAIDListCommand* cmd = [LCSAppleRAIDListCommand command];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-10.6"
                                                                                  ofType:@"txt"]];
    
    id taskMock = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:data stderrData:[NSData data]];
    cmd.task = taskMock;
    
    [cmd start];
    [cmd waitUntilDone];
    
    [taskMock verify];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expected LCSCommandStateFinished");
}

-(void) testListFailedController
{
    LCSAppleRAIDListCommand* cmd = [LCSAppleRAIDListCommand command];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-controller-failed"
                                                                                  ofType:@"txt"]];
    
    id taskMock = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:data stderrData:[NSData data]];
    cmd.task = taskMock;
    
    [cmd start];
    [cmd waitUntilDone];
    
    [taskMock verify];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFailed, @"Expected LCSCommandStateFailed");
}

- (void)testListNoRaidSetsFound
{
    LCSAppleRAIDListCommand* cmd = [LCSAppleRAIDListCommand command];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-no-raidsets-found"
                                                                                  ofType:@"txt"]];
    
    id taskMock = [OCMockObject mockTask:cmd.task withTerminationStatus:1 stdoutData:data stderrData:[NSData data]];
    cmd.task = taskMock;
    
    [cmd start];
    [cmd waitUntilDone];
    
    [taskMock verify];
    
    GHAssertEqualObjects(cmd.result, [NSArray array], @"Expected empty array");
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expected LCSCommandStateFinished");
}
@end
