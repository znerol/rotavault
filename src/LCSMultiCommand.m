//
//  LCSMultiCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSMultiCommand.h"


@implementation LCSMultiCommand
@synthesize controller;
@synthesize commands;

-(void)dealloc
{
    [controllers release];
    [commands release];
    [super dealloc];
}

-(void)setCommands:(NSArray *)newCommands
{
    NSAssert(controller.state == LCSCommandStateInit, @"Unable to assign new commands if state is not init");
    
    id tmp = commands;
    commands = [newCommands retain];
    [tmp release];
}

-(void)handleStateInvalidated:(LCSCommandController*)sender
{
    [sender removeObserver:self forState:LCSCommandStateInvalidated];
    
    invalidatedCound++;
    if (invalidatedCound == [controllers count]) {
        if (finishedCount == [controllers count]) {
            controller.state = LCSCommandStateFinished;
        }
        else if (controller.state == LCSCommandStateCancelling) {
            controller.state = LCSCommandStateCancelled;
        }
        else {
            controller.state = LCSCommandStateFailed;
        }
        controller.state = LCSCommandStateInvalidated;
    }
}

-(void)handleStateFailed:(LCSCommandController*)sender
{
    [sender removeObserver:self forState:LCSCommandStateFailed];
    failedCount++;
}

-(void)handleStateFinished:(LCSCommandController*)sender
{
    [sender removeObserver:self forState:LCSCommandStateFinished];
    finishedCount++;
}

-(void)handleStateCancelled:(LCSCommandController*)sender
{
    [sender removeObserver:self forState:LCSCommandStateCancelled];
    cancelledCount++;
}

-(void)start
{
    NSAssert(commands != nil && [commands count] > 0, @"At least one command needs to be given to a multicommand");
    
    NSMutableArray *tmpcontrollers = [NSMutableArray arrayWithCapacity:[commands count]];
    
    for (id <LCSCommand> command in commands) {
        LCSCommandController *ctl = [LCSCommandController controllerWithCommand:command];
        [ctl addObserver:self selector:@selector(handleStateInvalidated:) forState:LCSCommandStateInvalidated];
        [ctl addObserver:self selector:@selector(handleStateFailed:) forState:LCSCommandStateFailed];
        [ctl addObserver:self selector:@selector(handleStateFinished:) forState:LCSCommandStateFinished];
        [ctl addObserver:self selector:@selector(handleStateCancelled:) forState:LCSCommandStateCancelled];
        [tmpcontrollers addObject:ctl];
    }
    
    controllers = [tmpcontrollers copy];
    for (LCSCommandController *ctl in controllers) {
        [ctl start];
    }
    controller.state = LCSCommandStateRunning;
}

-(void)cancel
{
    for (LCSCommandController *ctl in controllers) {
        [ctl cancel];
    }
}
@end
