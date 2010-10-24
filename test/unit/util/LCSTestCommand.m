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

-(void)invalidate
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    self.state = LCSCommandStateInvalidated;
}

-(void)finishNow
{
    self.state = finalState;
    [self invalidate];
}

-(void)cancelNow
{
    self.state = LCSCommandStateCancelled;
    [self invalidate];
}

-(void)performStart
{
    self.state = LCSCommandStateRunning;
    [self performSelector:@selector(finishNow) withObject:nil afterDelay:delay];
}

-(void)performCancel
{
    [self performSelector:@selector(cancelNow) withObject:nil afterDelay:0];
}
@end
