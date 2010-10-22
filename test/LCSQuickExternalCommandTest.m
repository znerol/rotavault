//
//  LCSQuickExternalCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//


#import <GHUnit/GHUnit.h>
#import "LCSQuickExternalCommand.h"
#import "LCSCommandController.h"
#import "LCSTestdir.h"

@interface LCSQuickExternalCommandTest : GHTestCase {
    NSMutableArray *states;
    LCSQuickExternalCommand *cmd;
}
@end


@implementation LCSQuickExternalCommandTest
-(void)setUp
{
    states = [[NSMutableArray alloc] init];
    cmd = [[LCSQuickExternalCommand alloc] init];    
    [cmd addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:nil];
}

-(void)tearDown
{
    [cmd removeObserver:self forKeyPath:@"state"];
    
    [cmd release];
    cmd = nil;
    
    [states release];
    states = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != cmd) {
        return;
    }
    
    if ([keyPath isEqualToString:@"state"]) {
        [states addObject:[NSNumber numberWithInt:cmd.state]];
    }
}

-(void)testCommandWithZeroStatus
{
    [cmd.task setLaunchPath:@"/usr/bin/true"];
    
    [cmd start];
    [cmd waitUntilDone];
    
    NSArray *expectedStates = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:LCSCommandStateInit],
                               [NSNumber numberWithInt:LCSCommandStateStarting],
                               [NSNumber numberWithInt:LCSCommandStateRunning],
                               [NSNumber numberWithInt:LCSCommandStateFinished],
                               [NSNumber numberWithInt:LCSCommandStateInvalidated],
                               nil];
    
    GHAssertEqualObjects(states, expectedStates, @"Unexpected state sequence");
    
}


-(void)testCommandWithNonZeroStatus
{
    [cmd.task setLaunchPath:@"/usr/bin/false"];
    
    [cmd start];
    [cmd waitUntilDone];
    
    NSArray *expectedStates = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:LCSCommandStateInit],
                               [NSNumber numberWithInt:LCSCommandStateStarting],
                               [NSNumber numberWithInt:LCSCommandStateRunning],
                               [NSNumber numberWithInt:LCSCommandStateFailed],
                               [NSNumber numberWithInt:LCSCommandStateInvalidated],
                               nil];
    
    GHAssertEqualObjects(states, expectedStates, @"Unexpected state sequence");
}


-(void)testCommandCancel
{
    [cmd.task setLaunchPath:@"/bin/sleep"];
    [cmd.task setArguments:[NSArray arrayWithObject:@"10"]];
    
    [cmd start];
    [cmd cancel];
    [cmd waitUntilDone];
    
    NSArray *expectedStates = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:LCSCommandStateInit],
                               [NSNumber numberWithInt:LCSCommandStateStarting],
                               [NSNumber numberWithInt:LCSCommandStateRunning],
                               [NSNumber numberWithInt:LCSCommandStateCancelling],
                               [NSNumber numberWithInt:LCSCommandStateCancelled],
                               [NSNumber numberWithInt:LCSCommandStateInvalidated],
                               nil];
    
    GHAssertEqualObjects(states, expectedStates, @"Unexpected state sequence");
}

-(void)testCommandWithDirectoryPath
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    
    [cmd.task setLaunchPath:[testdir path]];
    
    [cmd start];
    [cmd waitUntilDone];
    
    NSArray *expectedStates = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:LCSCommandStateInit],
                               [NSNumber numberWithInt:LCSCommandStateStarting],
                               [NSNumber numberWithInt:LCSCommandStateFailed],
                               [NSNumber numberWithInt:LCSCommandStateInvalidated],
                               nil];
    
    GHAssertEqualObjects(states, expectedStates, @"Unexpected state sequence");
    
    [testdir remove];
    [testdir release];
}

-(void)testCommandWithNonExistingPath
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    
    [cmd.task setLaunchPath:[[testdir path] stringByAppendingPathComponent:@"nothing"]];
    
    [cmd start];
    [cmd waitUntilDone];
    
    NSArray *expectedStates = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:LCSCommandStateInit],
                               [NSNumber numberWithInt:LCSCommandStateStarting],
                               [NSNumber numberWithInt:LCSCommandStateFailed],
                               [NSNumber numberWithInt:LCSCommandStateInvalidated],
                               nil];
    
    GHAssertEqualObjects(states, expectedStates, @"Unexpected state sequence");
    
    [testdir remove];
    [testdir release];
}

-(void)testCommandWithNonExecutableFile
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    
    [cmd.task setLaunchPath:[[testdir path] stringByAppendingPathComponent:@"nothing"]];

    BOOL result = [@"no code at all!" writeToFile:[cmd.task launchPath] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    GHAssertEquals(result, YES, @"Failed to write helper file");
    
    [cmd start];
    [cmd waitUntilDone];
    
    NSArray *expectedStates = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:LCSCommandStateInit],
                               [NSNumber numberWithInt:LCSCommandStateStarting],
                               [NSNumber numberWithInt:LCSCommandStateFailed],
                               [NSNumber numberWithInt:LCSCommandStateInvalidated],
                               nil];
    
    GHAssertEqualObjects(states, expectedStates, @"Unexpected state sequence");
    
    [testdir remove];
    [testdir release];
}

-(void)testCommandWithStdout
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString *testpath = [[testdir path] stringByAppendingPathComponent:@"test.txt"];
    
    BOOL result = [@"TEST" writeToFile:testpath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    GHAssertEquals(result, YES, @"Failed to write helper file");
    
    [cmd.task setLaunchPath:@"/bin/cat"];
    [cmd.task setArguments:[NSArray arrayWithObject:testpath]];
    
    [cmd start];
    [cmd waitUntilDone];
    
    NSArray *expectedStates = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:LCSCommandStateInit],
                               [NSNumber numberWithInt:LCSCommandStateStarting],
                               [NSNumber numberWithInt:LCSCommandStateRunning],
                               [NSNumber numberWithInt:LCSCommandStateFinished],
                               [NSNumber numberWithInt:LCSCommandStateInvalidated],
                               nil];
    
    GHAssertEqualObjects(states, expectedStates, @"Unexpected state sequence");
    
    NSData *expectedData = [NSArray arrayWithObjects:
                            [@"TEST" dataUsingEncoding:NSUTF8StringEncoding], [NSData data], nil];
    GHAssertEqualObjects(cmd.result, expectedData, @"Unexpected result");
    
    [testdir remove];
    [testdir release];
}

-(void)testCommandWithStderrNonZeroExitStatus
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString *testscript = [[testdir path] stringByAppendingPathComponent:@"test.sh"];
    
    BOOL result = [@"#!/bin/sh\necho HELLO >&2\nexit 1" writeToFile:testscript
                                                         atomically:NO
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
    
    GHAssertEquals(result, YES, @"Failed to write helper script");
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSDictionary *executableAttribute = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:0755]
                                                                    forKey:NSFilePosixPermissions];
    result = [fm setAttributes:executableAttribute ofItemAtPath:testscript error:nil];
    GHAssertEquals(result, YES, @"Failed to chmod helper script");
    
    [cmd.task setLaunchPath:@"/bin/sh"];
    [cmd.task setArguments:[NSArray arrayWithObject:testscript]];
    
    [cmd start];
    [cmd waitUntilDone];
    
    NSArray *expectedStates = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:LCSCommandStateInit],
                               [NSNumber numberWithInt:LCSCommandStateStarting],
                               [NSNumber numberWithInt:LCSCommandStateRunning],
                               [NSNumber numberWithInt:LCSCommandStateFailed],
                               [NSNumber numberWithInt:LCSCommandStateInvalidated],
                               nil];
    
    GHAssertEqualObjects(states, expectedStates, @"Unexpected state sequence");
    
    NSData *expectedData = [NSArray arrayWithObjects:
                            [NSData data], [@"HELLO\n" dataUsingEncoding:NSUTF8StringEncoding], nil];
    GHAssertEqualObjects(cmd.result, expectedData, @"Unexpected result");
    
    [fm release];
    [testdir remove];
    [testdir release];
}
@end
