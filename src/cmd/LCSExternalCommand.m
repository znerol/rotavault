//
//  LCSExternalCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSExternalCommand.h"
#import "LCSCommand.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultError.h"


@implementation LCSExternalCommand
@synthesize task;

-(id)init
{
    /* keep the implementation in sync with the implementation in LCSExternalCommand+MockableTask.m */
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    task = [[NSTask alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(task);
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [task release];
    [super dealloc];
}

-(void)invalidate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:task];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancel) object:nil];
    self.state = LCSCommandStateInvalidated;
}

-(void)handleTaskTermination
{
    if ([task terminationStatus] != 0 && [self validateNextState:LCSCommandStateFailed]) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSExecutableReturnedNonZeroStatusError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"External helper tool terminated with exit status %d", [task terminationStatus]),
                                       LCSERROR_EXECUTABLE_TERMINATION_STATUS([task terminationStatus]),
                                       LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
        [self handleError:err];
    }
    else if ([self validateNextState:LCSCommandStateFinished]){
        self.state = LCSCommandStateFinished;
        [self invalidate];
    }
}

-(void)handleError:(NSError*)err
{
    self.error = err;
    self.state = LCSCommandStateFailed;
    
    if ([task isRunning]) {
        [task terminate];
    }
    else {
        [self invalidate];
    }
}

-(void)handleTerminationNotification:(NSNotification*)ntf
{
    if (self.state == LCSCommandStateCancelling) {
        self.state = LCSCommandStateCancelled;
        [self invalidate];
    }
    else if (self.state == LCSCommandStateFailed) {
        [self invalidate];
    }
    else {
        [self handleTaskTermination];
    }
}

-(void)performStart
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTerminationNotification:)
                                                 name:NSTaskDidTerminateNotification
                                               object:task];
    
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    BOOL isDirectory;
    
    NSError *err;
    if (![fm fileExistsAtPath:[task launchPath] isDirectory:&isDirectory]) {
        err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSLaunchOfExecutableFailedError,
                              LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to launch external helper tool at %@. No such file", [task launchPath]),
                              LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
        [self handleError:err];
        return;
    }
    else if (isDirectory) {
        err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSLaunchOfExecutableFailedError,
                              LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to launch external helper tool. %@ is a directory.", [task launchPath]),
                              LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
        [self handleError:err];
        return;
    }
    else if (![fm isExecutableFileAtPath:[task launchPath]]) {
        err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSLaunchOfExecutableFailedError,
                              LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to launch external helper tool. %@ is not executable.", [task launchPath]),
                              LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
        [self handleError:err];
        return;
    }
    
    @try {
        [task launch];
    }
    @catch (NSException *e) {
        err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSLaunchOfExecutableFailedError,
                              LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to launch external helper tool. %@", [e description]),
                              LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
        [self handleError:err];
        return;
    }
    
    self.state = LCSCommandStateRunning;
}

-(void)performCancel
{
    if ([task isRunning]) {
        [task terminate];
        NSLog(@"object: %@ cmd %@", [self description], NSStringFromSelector(_cmd));
        
        /*
         * Because of a race condition in NSTask it is possible that a freshly spawned task does not receive the TERM
         * signal. Therefore we just retry after one second.
         */
        [self performSelector:@selector(performCancel) withObject:nil afterDelay:0.2];
    }
}
@end
