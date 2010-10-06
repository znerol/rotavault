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
@synthesize controllers;

+(LCSMultiCommand*)command
{
    return [[[LCSMultiCommand alloc] init] autorelease];
}

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

-(void)handleStateInvalidated:(NSNotification*)ntf
{
    LCSCommandController *sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:sender];
    
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
        
        /* be sure to remove any stale observers from notification center before invalidating */
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        controller.state = LCSCommandStateInvalidated;
    }
}

-(void)handleStateFailed:(NSNotification*)ntf
{
    LCSCommandController *sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                                  object:sender];
    failedCount++;
}

-(void)handleStateFinished:(NSNotification*)ntf
{
    LCSCommandController *sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                                  object:sender];
    finishedCount++;
}

-(void)handleStateCancelled:(NSNotification*)ntf
{
    LCSCommandController *sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateCancelled]
                                                  object:sender];
    cancelledCount++;
}

-(void)start
{
    NSAssert(commands != nil && [commands count] > 0, @"At least one command needs to be given to a multicommand");
    
    NSMutableArray *tmpcontrollers = [NSMutableArray arrayWithCapacity:[commands count]];
    
    for (id <LCSCommand> command in commands) {
        LCSCommandController *ctl = [LCSCommandController controllerWithCommand:command];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStateInvalidated:)
                                                     name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                                   object:controller];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStateFailed:)
                                                     name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                                   object:controller];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStateFinished:)
                                                     name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                                   object:controller];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStateCancelled:)
                                                     name:[LCSCommandController notificationNameStateEntered:LCSCommandStateCancelled]
                                                   object:controller];
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
