//
//  LCSTestObserver.m
//  rotavault
//
//  Created by Lorenz Schori on 02.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTestObserver.h"
#import "LCSInitMacros.h"


@implementation LCSTestObserver
- (id)initWithDelay:(NSTimeInterval)aDelay finalState:(LCSObserverState)aState
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    delay = aDelay;
    finalState = aState;
    
    return self;
}

+ (LCSTestObserver*)observerWithDelay:(NSTimeInterval)aDelay finalState:(LCSObserverState)aState
{
    return [[[LCSTestObserver alloc] initWithDelay:aDelay finalState:aState] autorelease];
}

- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [value release];
    [super dealloc];
}

- (void)performInstall
{
    self.state = LCSObserverStateInstalled;
}

- (void)performRemove
{
    self.state = LCSObserverStateRemoved;
}

- (void)finishRefreshNow
{
    self.state = LCSObserverStateFresh;
}

- (void)performStartRefresh
{
    self.state = LCSObserverStateRefreshing;
    [self performSelector:@selector(finishRefreshNow) withObject:nil afterDelay:delay];
}
@end
