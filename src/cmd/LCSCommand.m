//
//  LCSCommandController.m
//  task-test-2
//
//  Created by Lorenz Schori on 23.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSCommand.h"
#import "LCSInitMacros.h"

@implementation LCSCommand
@synthesize state;
@synthesize exitState;
@synthesize title;
@synthesize progress;
@synthesize progressMessage;
@synthesize progressAnimate;
@synthesize progressIndeterminate;
@synthesize cancellable;
@synthesize pausable;
@synthesize resumable;
@synthesize result;
@synthesize error;

-(void)dealloc
{
    [title release];
    [progressMessage release];
    [result release];
    [error release];
    [super dealloc];
}

-(BOOL)validateNextState:(LCSCommandState)newState
{
    static LCSCommandState statematrix[LCSCommandStateCount][LCSCommandStateCount] = {
        //in, sig, run, pig, psd, res, fin, fld, cig, ced, inv
        { NO, YES,  NO,  NO,  NO,  NO,  NO, YES,  NO,  NO,  NO },   // LCSCommandStateInit
        { NO,  NO, YES,  NO,  NO,  NO,  NO, YES,  NO,  NO,  NO },   // LCSCommandStateStarting
        { NO,  NO,  NO, YES,  NO,  NO, YES, YES, YES,  NO,  NO },   // LCSCommandStateRunning
        { NO,  NO,  NO,  NO, YES,  NO,  NO, YES,  NO,  NO,  NO },   // LCSCommandStatePausing
        { NO,  NO,  NO,  NO,  NO, YES,  NO, YES, YES,  NO,  NO },   // LCSCommandStatePaused
        { NO,  NO, YES,  NO,  NO,  NO,  NO, YES,  NO,  NO,  NO },   // LCSCommandStateResuming
        { NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, YES },   // LCSCommandStateFinished
        { NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, YES },   // LCSCommandStateFailed
        { NO,  NO,  NO,  NO,  NO,  NO,  NO, YES,  NO, YES,  NO },   // LCSCommandStateCancelling
        { NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, YES },   // LCSCommandStateCancelled
        { NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO }    // LCSCommandStateInvalidated
    };
    
    /*
    if ((![command respondsToSelector:@selector(cancel)] &&
         (newState == LCSCommandStateCancelling || newState == LCSCommandStateCancelled))) {
        return NO;
    }
    else if (((![command respondsToSelector:@selector(pause)] || ![command respondsToSelector:@selector(resume)]) &&
              (newState == LCSCommandStatePausing || newState == LCSCommandStatePaused ||
               newState == LCSCommandStateResuming)))
    {
        return NO;
        
    }
    else {
     */
        return statematrix[state][newState];
    /*
    }
     */
}

-(void)setState:(LCSCommandState)newState
{
    NSParameterAssert([self validateNextState:newState]);
    
    LCSCommandState oldState = state;
    if (newState == LCSCommandStateInvalidated) {
        exitState = state;
    }
    
    state = newState;
    
    self.cancellable = [self validateNextState:LCSCommandStateCancelling];
    self.pausable = [self validateNextState:LCSCommandStatePausing];
    self.resumable = [self validateNextState:LCSCommandStateResuming];
    
    switch (state) {
        case LCSCommandStateStarting:
        case LCSCommandStateRunning:
        case LCSCommandStatePausing:
        case LCSCommandStatePaused:
        case LCSCommandStateResuming:
        case LCSCommandStateCancelling:
            self.progressAnimate = YES;
            break;
        default:
            self.progressAnimate = NO;
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:[[self class] notificationNameStateLeft:oldState] object:self];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:[[self class] notificationNameStateTransfered:oldState toState:newState] object:self];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:[[self class] notificationNameStateEntered:newState] object:self];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:[[self class] notificationNameStateChanged] object:self];
}

-(void)start
{
    if ([self validateNextState:LCSCommandStateStarting]) {
        self.progressIndeterminate = YES;
        self.progressMessage = @"Starting";
        self.state = LCSCommandStateStarting;
        [self performStart];
    }
}

-(void)cancel
{
    if ([self validateNextState:LCSCommandStateCancelling]) {
        self.progressIndeterminate = YES;
        self.progressMessage = @"Cancelling";
        self.state = LCSCommandStateCancelling;
        [self performCancel];
    }
}

-(void)performStart
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"[LCSCommandController start] is a pure virtual method. You have to override it in a subclass"
                                 userInfo:nil];    
}

-(void)performCancel
{
}

+(NSString*)notificationNameStateLeft:(LCSCommandState)oldState
{
    return [NSString stringWithFormat:@"LCSCommandControllerLeftState-%d", oldState];
}

+(NSString*)notificationNameStateTransfered:(LCSCommandState)oldState toState:(LCSCommandState)newState
{
    return [NSString stringWithFormat:@"LCSCommandControllerTransfered-%d-%d", oldState, newState];
}

+(NSString*)notificationNameStateEntered:(LCSCommandState)newState
{
    return [NSString stringWithFormat:@"LCSCommandControllerEnteredState-%d", newState];
}

+(NSString*)notificationNameStateChanged
{
    return @"LCSCommandControllerStateChanged";
}

@end

@implementation LCSCommand (RunLoopHelpers)
-(void)waitUntilDone
{
    while (state != LCSCommandStateInvalidated) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
}
@end
