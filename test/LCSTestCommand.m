//
//  LCSFailingTestCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTestCommand.h"
#import "LCSInitMacros.h"


@implementation LCSTestCommand
@synthesize controller;


-(id)init
{
    return [self initWithDelay:0 finalState:LCSCommandStateFinished];
}

-(id)initWithDelay:(NSTimeInterval)inDelay finalState:(LCSCommandState)inState
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    delay = inDelay;
    finalState = inState;
    
    return self;
}

+(LCSTestCommand*)commandWithDelay:(NSTimeInterval)inDelay finalState:(LCSCommandState)inState
{
    return [[[LCSTestCommand alloc] initWithDelay:inDelay finalState:inState] autorelease];
}

-(void)performComplete
{
    controller.state = finalState;
    controller.state = LCSCommandStateInvalidated;
}

-(void)performCancel
{
    controller.state = LCSCommandStateCancelled;
    controller.state = LCSCommandStateInvalidated;
}

-(void)start
{
    controller.state = LCSCommandStateRunning;
    [self performSelector:@selector(performComplete) withObject:nil afterDelay:delay];
}

-(void)cancel
{
    [self performSelector:@selector(performCancel) withObject:nil afterDelay:0];
}
@end
