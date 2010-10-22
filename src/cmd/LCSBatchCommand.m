//
//  LCSBatchCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 12.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultBlockCopyCommand.h"
#import "LCSInitMacros.h"
#import "LCSCommand.h"
#import "LCSRotavaultError.h"

@implementation LCSBatchCommand
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    activeCommands = [[LCSCommandCollection alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(activeCommands);
    
    [activeCommands watchState:LCSCommandStateFailed];
    [activeCommands watchState:LCSCommandStateCancelled];
    [activeCommands watchState:LCSCommandStateFinished];
    [activeCommands watchState:LCSCommandStateInvalidated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCollectionFailed:)
                                                 name:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFailed]
                                               object:activeCommands];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCollectionCancelled:)
                                                 name:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateCancelled]
                                               object:activeCommands];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCollectionInvalidated:)
                                                 name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateInvalidated]
                                               object:activeCommands];
    
    return self;
}

-(void)dealloc
{
    [activeCommands release];
    [super dealloc];
}

-(void)invalidate
{
    [activeCommands unwatchState:LCSCommandStateInvalidated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.state = LCSCommandStateInvalidated;
}

-(void)handleError:(NSError*)err
{
    if (self.state == LCSCommandStateInvalidated) {
        return;
    }
    
    [activeCommands unwatchState:LCSCommandStateFailed];
    [activeCommands unwatchState:LCSCommandStateCancelled];
    [activeCommands unwatchState:LCSCommandStateFinished];
    
    self.error = err;
    self.state = LCSCommandStateFailed;
    
    for (LCSCommand *ctl in activeCommands.commands) {
        [ctl cancel];
    }
}

-(void)commandCollectionFailed:(NSNotification*)ntf
{
    LCSCommandCollection* sender = [ntf object];
    LCSCommand* originalSender = [[ntf userInfo] objectForKey:LCSCommandCollectionOriginalSenderKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFailed]
                                                  object:sender];
    [self handleError:originalSender.error];
}

-(void)commandCollectionCancelled:(NSNotification*)ntf
{
    LCSCommandCollection* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateCancelled]
                                                  object:sender];
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];
}

-(void)commandCollectionInvalidated:(NSNotification*)ntf
{
    [self invalidate];    
}
@end
