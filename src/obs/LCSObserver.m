//
//  LCSObserver.m
//  rotavault
//
//  Created by Lorenz Schori on 02.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSObserver.h"

@interface LCSObserver (Internal)
- (void)notifyObserversIfValueFresh;
@end


@implementation LCSObserver
@synthesize state;
@synthesize value;
@synthesize autorefresh;

NSString *LCSObserverStateName[LCSObserverStateCount] = {
    @"Init",
    @"Installed",
    @"Refreshing",
    @"Fresh",
    @"Stale",
    @"Removed",
};

- (void)dealloc
{
    [value release];
    [super dealloc];
}

- (BOOL)validateNextState:(LCSObserverState)newState
{
    static LCSObserverState statematrix[LCSObserverStateCount][LCSObserverStateCount] = {
        //in, ild, rsh, fsh, stl, rmv
        { NO, YES,  NO,  NO,  NO,  NO },   // LCSObserverStateInit
        { NO,  NO, YES,  NO,  NO, YES },   // LCSObserverStateInstalled
        { NO,  NO,  NO, YES,  NO, YES },   // LCSObserverStateRefreshing
        { NO,  NO,  NO,  NO, YES, YES },   // LCSObserverStateFresh
        { NO,  NO, YES,  NO,  NO, YES },   // LCSObserverStateStale
        { NO,  NO,  NO,  NO,  NO,  NO }    // LCSObserverStateRemoved
    };
    
    if (newState < 0 || newState > LCSObserverStateRemoved) {
        return NO;
    }
    else {
        return statematrix[state][newState];
    }
}

- (void)setState:(LCSObserverState)newState
{
    BOOL validState = [self validateNextState:newState];
    if (!validState) {
        if (newState < 0 || newState > LCSObserverStateRemoved) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Attempt to set state to an invalid value"
                                         userInfo:nil];
        }
        else {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:
                                                   @"Attempt invalid state transition from %@ (%d) to %@ (%d)",
                                                   LCSObserverStateName[state], state, LCSObserverStateName[newState],
                                                   newState]
                                         userInfo:nil];
        }
    }
    
    LCSObserverState oldState = state;    
    state = newState;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:[[self class] notificationNameStateLeft:oldState] object:self];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:[[self class] notificationNameStateTransfered:oldState toState:newState] object:self];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:[[self class] notificationNameStateEntered:newState] object:self];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:[[self class] notificationNameStateChanged] object:self];
    
    /* Post LCSObserverValueFreshNotification if the value is fresh */
    [self notifyObserversIfValueFresh];
    
    /* Start refreshing the value if requested */
    if (autorefresh && [self validateNextState:LCSObserverStateRefreshing]) {
        [self performStartRefresh];
    }
}

- (void)performInstall
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"[LCSObserver performInstall] is a pure virtual method. You have to override it in a subclass"
                                 userInfo:nil];    
}

- (void)performRemove
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"[LCSObserver performRemove] is a pure virtual method. You have to override it in a subclass"
                                 userInfo:nil];    
}

- (void)performStartRefresh
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"[LCSObserver performStartRefresh] is a pure virtual method. You have to override it in a subclass"
                                 userInfo:nil];    
}

- (void)install
{
    if ([self validateNextState:LCSObserverStateInstalled]) {
        [self performInstall];
    }
}

- (void)remove
{
    if ([self validateNextState:LCSObserverStateRemoved]) {
        [self performRemove];
    }
}

- (void)notifyObserversIfValueFresh
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(notifyObserversIfValueFresh)
                                                   object:nil];
    
    if (state == LCSObserverStateFresh) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:[[self class] notificationNameValueFresh] object:self];
    }
}

- (void)refreshInBackgroundAndNotify
{
    if ([self validateNextState:LCSObserverStateRefreshing]) {
        [self performStartRefresh];
    }
    
    [self performSelector:@selector(notifyObserversIfValueFresh) withObject:nil afterDelay:0];
}

+(NSString*)notificationNameStateLeft:(LCSObserverState)oldState
{
    return [NSString stringWithFormat:@"LCSObserverLeftState-%d", oldState];
}

+(NSString*)notificationNameStateTransfered:(LCSObserverState)oldState toState:(LCSObserverState)newState
{
    return [NSString stringWithFormat:@"LCSObserverTransfered-%d-%d", oldState, newState];
}

+(NSString*)notificationNameStateEntered:(LCSObserverState)newState
{
    return [NSString stringWithFormat:@"LCSObserverEnteredState-%d", newState];
}

+(NSString*)notificationNameStateChanged
{
    return @"LCSObserverStateChanged";
}

+(NSString*)notificationNameValueFresh
{
    return @"LCSObserverValueFresh";
}
@end

@implementation LCSObserver (RunLoopHelpers)

-(void)stopRunLoopNow
{
    CFRunLoopStop([[NSRunLoop currentRunLoop] getCFRunLoop]);
}

-(void)stopScheduleRunLoopStop
{
    [[NSRunLoop currentRunLoop] performSelector:@selector(stopRunLoopNow)
                                         target:self
                                       argument:nil
                                          order:NSUIntegerMax
                                          modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
}

-(void)waitUntil:(LCSObserverState)exitState
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopRunLoopNow)
                                                 name:[[self class] notificationNameStateEntered:exitState]
                                               object:self];
    
    while (state != exitState) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[[self class] notificationNameStateEntered:exitState]
                                                  object:self];
}
@end
