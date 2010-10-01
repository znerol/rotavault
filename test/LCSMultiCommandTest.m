//
//  LCSMultiCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSMultiCommandTest.h"
#import "LCSTestCommand.h"


// FIXME: should not be necessary to access controllers via category...

@interface LCSMultiCommand (controllers)
@property(readonly,retain) NSArray* controllers;
@end

@implementation LCSMultiCommand (controllers)
-(NSArray*)controllers
{
    return controllers;
}
@end


@implementation LCSMultiCommandTest
-(void)setUp
{
    states = [[NSMutableArray alloc] init];
    
    mgr = [[LCSCommandManager alloc] init];
    cmd = [[LCSMultiCommand alloc] init];
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

-(void)testMultiCommandWithoutCommand
{
    GHAssertThrows([ctl start], @"Start of a multi command must fail if it does not contain any commands");
}

-(void)testMultiCommandWithOneSuccessfullCommand
{
    cmd.commands = [NSArray arrayWithObject:[LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished]];
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

-(void)testMultiCommandWithOneFailingCommand
{
    cmd.commands = [NSArray arrayWithObject:[LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFailed]];
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

-(void)testMultiCommandWithOneCancelledCommand
{
    cmd.commands = [NSArray arrayWithObject:[LCSTestCommand commandWithDelay:10 finalState:LCSCommandStateFinished]];
    [ctl start];
    
    // FIXME: should not be necessary to access controllers via category...
    [[cmd.controllers objectAtIndex:0] cancel];
    
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

-(void)testMultiCommandWithManySuccessfullCommands
{
    cmd.commands = [NSArray arrayWithObjects:
                    [LCSTestCommand commandWithDelay:0.01 finalState:LCSCommandStateFinished],
                    [LCSTestCommand commandWithDelay:0.02 finalState:LCSCommandStateFinished],
                    [LCSTestCommand commandWithDelay:0.05 finalState:LCSCommandStateFinished],
                    nil];
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

-(void)testMultiCommandWithOneFailingManySuccessfullCommand
{
    cmd.commands = [NSArray arrayWithObjects:
                    [LCSTestCommand commandWithDelay:0.01 finalState:LCSCommandStateFinished],
                    [LCSTestCommand commandWithDelay:0.02 finalState:LCSCommandStateFailed],
                    [LCSTestCommand commandWithDelay:0.05 finalState:LCSCommandStateFinished],
                    nil];
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

-(void)testCancellingMultiCommandWithManySuccessfullCommands
{
    cmd.commands = [NSArray arrayWithObjects:
                    [LCSTestCommand commandWithDelay:10 finalState:LCSCommandStateFinished],
                    [LCSTestCommand commandWithDelay:10 finalState:LCSCommandStateFinished],
                    [LCSTestCommand commandWithDelay:10 finalState:LCSCommandStateFinished],
                    nil];
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

@end
