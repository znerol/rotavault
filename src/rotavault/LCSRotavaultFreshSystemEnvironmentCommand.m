//
//  LCSRotavaultFreshSystemEnvironmentCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 01.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultFreshSystemEnvironmentCommand.h"
#import "LCSInitMacros.h"


@interface LCSRotavaultFreshSystemEnvironmentCommand (Internals)
- (void)invalidate;
- (void)completeRefreshSystemEnvironment:(NSNotification*)ntf;
@end


@implementation LCSRotavaultFreshSystemEnvironmentCommand
+ (LCSRotavaultFreshSystemEnvironmentCommand*)commandWithSystemEnvironmentObserver:(LCSRotavaultSystemEnvironmentObserver*)newObserver
{
    return [[[LCSRotavaultFreshSystemEnvironmentCommand alloc] initWithSystemEnvironmentObserver:newObserver]
            autorelease]; 
}

+ (LCSRotavaultFreshSystemEnvironmentCommand*)commandWithDefaultSystemEnvironmentObserver
{
    return [LCSRotavaultFreshSystemEnvironmentCommand commandWithSystemEnvironmentObserver:
            [LCSRotavaultSystemEnvironmentObserver defaultSystemEnvironmentObserver]];
}

- (id)initWithSystemEnvironmentObserver:(LCSRotavaultSystemEnvironmentObserver*)newObserver
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    observer = [newObserver retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(observer);
    
    return self;
}

- (id)initWithDefaultSystemEnvironmentObserver
{
    return [self initWithSystemEnvironmentObserver:
            [LCSRotavaultSystemEnvironmentObserver defaultSystemEnvironmentObserver]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [observer release];
    [super dealloc];
}

- (void)invalidate
{
    self.state = LCSCommandStateInvalidated;
}

- (void)completeRefreshSystemEnvironment:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LCSRotavaultSystemEnvironmentRefreshed
                                                  object:observer];
    self.result = observer.registry;
    self.state = LCSCommandStateFinished;
    
    [self invalidate];
}

- (void)performStart
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeRefreshSystemEnvironment:)
                                                 name:LCSRotavaultSystemEnvironmentRefreshed
                                               object:observer];
    [observer refreshInBackgroundAndNotify];
    self.state = LCSCommandStateRunning;
}
@end
