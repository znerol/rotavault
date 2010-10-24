//
//  LCSCommand.h
//  task-test-2
//
//  Created by Lorenz Schori on 23.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    LCSCommandStateInit = 0,

    LCSCommandStateStarting,   // set by base class in start-selector
    LCSCommandStateRunning,    // set by command when the start-selector completes
    
    LCSCommandStatePausing,    // set by base class in pause-selector
    LCSCommandStatePaused,     // set by command when the pase-selector completes
    LCSCommandStateResuming,   // set by base class in resume-selector
    
    LCSCommandStateFinished,   // set by command when task has finished
    LCSCommandStateFailed,     // set by command when something went wrong
    LCSCommandStateCancelling, // set by base class in cancel-selector
    LCSCommandStateCancelled,  // set by command when the cancel-selector completes
    
    LCSCommandStateInvalidated, // set by command when task is ready to get disposed
    
    LCSCommandStateCount
} LCSCommandState;

extern NSString *LCSCommandStateName[LCSCommandStateCount];

@interface LCSCommand : NSObject {
    LCSCommandState  state;
    LCSCommandState  exitState;
    
    NSString *title;
    float progress;
    NSString *progressMessage;
    BOOL cancellable;
    BOOL pausable;
    BOOL resumable;
    BOOL progressAnimate;
    BOOL progressIndeterminate;
    
    id result;
    NSError* error;
}

@property(assign) LCSCommandState  state;
@property(assign) LCSCommandState  exitState;

@property(retain) NSString *title;
@property(assign) float progress;
@property(retain) NSString *progressMessage;
@property(assign) BOOL cancellable;
@property(assign) BOOL pausable;
@property(assign) BOOL resumable;
@property(assign) BOOL progressAnimate;
@property(assign) BOOL progressIndeterminate;

@property(retain) id result;
@property(retain) NSError* error;

-(BOOL)validateNextState:(LCSCommandState)newState;
-(void)start;
-(void)cancel;
@end

@interface LCSCommand (SubclassOverride)
/**
 * Start a background command. This method should not perform any substantial work but prepare the command for
 * asynchronous processing. Typically you start an NSTask or submit an NSOperation to a queue and let the magic happen
 * in the background.
 */
-(void)performStart;

/**
 * If implemented this method must initiate the cancellation of the background command. The implementation must switch
 * the state to LCSCommandStateCancelled at the end of the method.
 */
-(void)performCancel;
@end

@interface LCSCommand (NotificationHelpers)
+(NSString*)notificationNameStateLeft:(LCSCommandState)oldState;
+(NSString*)notificationNameStateTransfered:(LCSCommandState)oldState toState:(LCSCommandState)newState;
+(NSString*)notificationNameStateEntered:(LCSCommandState)newState;
+(NSString*)notificationNameStateChanged;
@end

@interface LCSCommand (RunLoopHelpers)
-(void)waitUntilDone;
@end
