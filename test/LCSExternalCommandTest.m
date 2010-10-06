//
//  LCSExternalCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSExternalCommand.h"
#import "LCSCommandController.h"
#import "LCSCommandManager.h"
#import "LCSTestdir.h"


@interface LCSExternalCommandTest : GHTestCase {
    NSMutableArray *states;
    LCSCommandManager *mgr;
    LCSExternalCommand *cmd;
    LCSCommandController *ctl;
}
@end


@implementation LCSExternalCommandTest

-(void)setUp
{
    states = [[NSMutableArray alloc] init];

    mgr = [[LCSCommandManager alloc] init];
    cmd = [[LCSExternalCommand alloc] init];
    ctl = [[LCSCommandController controllerWithCommand:cmd] retain];
    
    [mgr addCommandController:ctl];
    [ctl addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:nil];
}

-(void)tearDown
{
    [ctl removeObserver:self forKeyPath:@"state"];
    [mgr removeCommandController:ctl];
    
    [ctl release];
    ctl = nil;
    [cmd release];
    cmd = nil;
    [mgr release];
    mgr = nil;
    
    [states release];
    states = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != ctl) {
        return;
    }
    
    if ([keyPath isEqualToString:@"state"]) {
        [states addObject:[NSNumber numberWithInt:ctl.state]];
    }
}

-(void)testCommandWithZeroStatus
{
    [cmd.task setLaunchPath:@"/usr/bin/true"];
    [ctl start];
    
    [mgr waitUntilAllCommandsAreDone];
    
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
    [ctl start];
    
    [mgr waitUntilAllCommandsAreDone];
    
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
    
    [ctl start];
    [ctl cancel];
    
    [mgr waitUntilAllCommandsAreDone];
    
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
    [ctl start];
    
    [mgr waitUntilAllCommandsAreDone];
    
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
    [ctl start];
    
    [mgr waitUntilAllCommandsAreDone];
    
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
    
    [ctl start];
    
    [mgr waitUntilAllCommandsAreDone];
    
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
@end
