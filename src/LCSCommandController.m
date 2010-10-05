//
//  LCSCommandController.m
//  task-test-2
//
//  Created by Lorenz Schori on 23.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSCommandController.h"
#import "LCSInitMacros.h"

@implementation LCSCommandController
@synthesize command;
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
@synthesize userInfo;

+(LCSCommandController*)controllerWithCommand:(id <LCSCommand>)anCommand
{
    LCSCommandController* controller = [[LCSCommandController alloc] init];
    controller.command = anCommand;
    
    return [controller autorelease];
}

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    /* 
     * setup an array of map tables allowing us to use observer objects as keys (without copying) and selectors (SEL) as 
     * values for each LCSCommandState.
     */
    NSPointerFunctions *keyfunc = [NSPointerFunctions pointerFunctionsWithOptions:
                                   NSPointerFunctionsZeroingWeakMemory|NSPointerFunctionsObjectPointerPersonality];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(keyfunc);
    NSPointerFunctions *valfunc = [NSPointerFunctions pointerFunctionsWithOptions:
                                   NSPointerFunctionsZeroingWeakMemory|NSPointerFunctionsOpaquePersonality];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(valfunc);
    
    /* set a description function for the SEL pointers */
    typedef NSString *(*descriptionFunction_t)(const void *item);
    [valfunc setDescriptionFunction:(descriptionFunction_t)NSStringFromSelector];
    
    for (int i = 0; i < LCSCommandStateCount; i++) {
        observers[i] = [[NSMapTable alloc] initWithKeyPointerFunctions:keyfunc
                                                 valuePointerFunctions:valfunc
                                                              capacity:0];
        LCSINIT_RELEASE_AND_RETURN_IF_NIL(observers);
    }
    
    return self;
}

-(void)dealloc
{
    for (int i = 0; i < LCSCommandStateCount; i++) {
        [observers[i] release];
    }

    [command release];
    [title release];
    [progressMessage release];
    [result release];
    [error release];
    [super dealloc];
}

-(void)setCommand:(id <LCSCommand>)anCommand
{
    NSParameterAssert(anCommand != nil);
    NSParameterAssert(anCommand.controller == nil);
    
    NSAssert(command == nil, @"The controllers command may not be set more than once");
    
    command = [anCommand retain];
    command.controller = self;
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
        return statematrix[state][newState];
    }
}

-(void)setState:(LCSCommandState)newState
{
    NSParameterAssert([self validateNextState:newState]);
    
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
    
    /* notify observers */
    NSMapTable* observersForState = [observers[newState] copy];
    for (id observer in observersForState) {
        [observer performSelector:(SEL)[observersForState objectForKey:observer] withObject:self];
    }
    [observersForState release];
}

-(void)addObserver:(id)observer selector:(SEL)selector forState:(LCSCommandState)newState
{
    NSParameterAssert(newState >= 0);
    NSParameterAssert(newState < LCSCommandStateCount);
    
    NSMapTable* observersForState = observers[newState];
    [observersForState setObject:(id)selector forKey:observer];
}

-(void)removeObserver:(id)observer forState:(LCSCommandState)newState
{
    NSParameterAssert(newState >= 0);
    NSParameterAssert(newState < LCSCommandStateCount);
    
    NSMapTable* observersForState = observers[newState];
    [observersForState removeObjectForKey:observer];
}

-(void)start
{
    if ([self validateNextState:LCSCommandStateStarting]) {
        self.progressIndeterminate = YES;
        self.progressMessage = @"Starting";
        self.state = LCSCommandStateStarting;
        [command start];
    }
}

-(void)cancel
{
    if ([self validateNextState:LCSCommandStateCancelling]) {
        self.progressIndeterminate = YES;
        self.progressMessage = @"Cancelling";
        self.state = LCSCommandStateCancelling;
        [command cancel];
    }
}

-(void)pause
{
    if ([self validateNextState:LCSCommandStatePausing]) {
        self.state = LCSCommandStatePausing;
        [command pause];
    }
}

-(void)resume
{
    if ([self validateNextState:LCSCommandStateResuming]) {
        self.state = LCSCommandStateResuming;
        [command resume];
    }
}
@end
