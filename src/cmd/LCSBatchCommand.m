//
//  LCSBatchCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 12.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultBlockCopyCommand.h"
#import "LCSInitMacros.h"
#import "LCSCommandController.h"
#import "LCSRotavaultError.h"

@implementation LCSBatchCommand
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    activeControllers = [[LCSCommandControllerCollection alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(activeControllers);
    
    [activeControllers watchState:LCSCommandStateFailed];
    [activeControllers watchState:LCSCommandStateCancelled];
    [activeControllers watchState:LCSCommandStateFinished];
    [activeControllers watchState:LCSCommandStateInvalidated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCollectionFailed:)
                                                 name:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFailed]
                                               object:activeControllers];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCollectionCancelled:)
                                                 name:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateCancelled]
                                               object:activeControllers];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCollectionInvalidated:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateInvalidated]
                                               object:activeControllers];
    
    return self;
}

-(void)dealloc
{
    [activeControllers release];
    [super dealloc];
}

-(void)invalidate
{
    [activeControllers unwatchState:LCSCommandStateInvalidated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.state = LCSCommandStateInvalidated;
}

-(void)handleError:(NSError*)err
{
    if (self.state == LCSCommandStateInvalidated) {
        return;
    }
    
    [activeControllers unwatchState:LCSCommandStateFailed];
    [activeControllers unwatchState:LCSCommandStateCancelled];
    [activeControllers unwatchState:LCSCommandStateFinished];
    
    self.error = err;
    self.state = LCSCommandStateFailed;
    
    for (LCSCommandController *ctl in activeControllers.controllers) {
        [ctl cancel];
    }
}

-(void)commandCollectionFailed:(NSNotification*)ntf
{
    LCSCommandControllerCollection* sender = [ntf object];
    LCSCommandController* originalSender = [[ntf userInfo] objectForKey:LCSCommandControllerCollectionOriginalSenderKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFailed]
                                                  object:sender];
    [self handleError:originalSender.error];
}

-(void)commandCollectionCancelled:(NSNotification*)ntf
{
    LCSCommandControllerCollection* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateCancelled]
                                                  object:sender];
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];
}

-(void)commandCollectionInvalidated:(NSNotification*)ntf
{
    [self invalidate];    
}
@end
