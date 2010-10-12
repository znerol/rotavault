//
//  LCSCommand.h
//  task-test-2
//
//  Created by Lorenz Schori on 23.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LCSCommandRunner;
@class LCSCommandController;

@protocol LCSCommand <NSObject>

/**
 * A reference to the command controller. This value is set automatically via dependency injection.
 */
@property(assign) LCSCommandController* controller;

/**
 * Start a background command. This method should not perform any substantial work but prepare the command for
 * asynchronous processing. Typically you start an NSTask or submit an NSOperation to a queue and let the magic happen
 * in the background.
 */
-(void)start;

/**
 * If implemented this method must initiate the cancellation of the background command. The implementation must switch
 * the state to LCSCommandStateCancelled at the end of the method.
 */
@optional
-(void)cancel;

/**
 * If implemented this method must initiate pausing of the background command. The implementation must switch to state
 * LCSCommandStatusPaused after completion.
 */
@optional
-(void)pause;

/**
 * If implemented this method must resume a paused background command. The implementation must switch to state
 * LCSCommandStatusRunning after completion.
 */
@optional
-(void)resume;

@end
