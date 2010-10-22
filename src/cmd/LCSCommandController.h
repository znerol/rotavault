//
//  LCSCommandController.h
//  task-test-2
//
//  Created by Lorenz Schori on 23.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandTemp.h"


typedef enum {
    LCSCommandStateInit = 0,

    LCSCommandStateStarting,   // set by controller in start-selector
    LCSCommandStateRunning,    // set by command when the start-selector completes
    
    LCSCommandStatePausing,    // set by controller in pause-selector
    LCSCommandStatePaused,     // set by command when the pase-selector completes
    LCSCommandStateResuming,   // set by controller in resume-selector
    
    LCSCommandStateFinished,   // set by command when task has finished
    LCSCommandStateFailed,     // set by command when something went wrong
    LCSCommandStateCancelling, // set by controller in cancel-selector
    LCSCommandStateCancelled,  // set by command when the cancel-selector completes
    
    LCSCommandStateInvalidated, // set by command when task is ready to get disposed
    
    LCSCommandStateCount
} LCSCommandState;

@interface LCSCommandController : NSObject {
    LCSCommandState  state;
    LCSCommandState  exitState;
    id <LCSCommandTemp>  command;
    
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
    
    id userInfo;
}

@property(assign) LCSCommandState  state;
@property(assign) LCSCommandState  exitState;
@property(retain) id <LCSCommandTemp>  command;

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

@property(assign) id userInfo;

+(LCSCommandController*)controllerWithCommand:(id <LCSCommandTemp>)anCommand;

-(BOOL)validateNextState:(LCSCommandState)newState;
-(BOOL)tryStart;
-(BOOL)tryCancel;

@end

@interface LCSCommandController (NotificationHelpers)
+(NSString*)notificationNameStateLeft:(LCSCommandState)oldState;
+(NSString*)notificationNameStateTransfered:(LCSCommandState)oldState toState:(LCSCommandState)newState;
+(NSString*)notificationNameStateEntered:(LCSCommandState)newState;
+(NSString*)notificationNameStateChanged;
@end

@interface LCSCommandController (RunLoopHelpers)
-(void)waitUntilDone;
@end
