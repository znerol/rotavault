//
//  LCSExternalCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSExternalCommand.h"
#import "LCSCommandController.h"
#import "LCSInitMacros.h"


@implementation LCSExternalCommand
@synthesize controller;
@synthesize task;

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    task = [[NSTask alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(task);
    
    return self;
}

-(void)dealloc
{
    [task release];
    [super dealloc];
}

-(void)invalidate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:task];
    controller.state = LCSCommandStateInvalidated;
}

-(void)taskCancelled
{
    controller.state = LCSCommandStateCancelled;
    [self invalidate];    
}

-(void)taskCompleted
{
    controller.state = LCSCommandStateFinished;
    [self invalidate];
}

-(void)taskFailedToLaunchWithErrorDescription:(NSString*)errorDescription
{
    controller.state = LCSCommandStateFailed;
    [self invalidate];
}

-(void)taskFailedWithStatus:(int)status
{
    controller.state = LCSCommandStateFailed;
    [self invalidate];
}

-(void)handleTerminationNotification:(NSNotification*)ntf
{
    if (controller.state == LCSCommandStateCancelling) {
        [self taskCancelled];
    }
    else if ([task terminationStatus] != 0) {
        [self taskFailedWithStatus:[task terminationStatus]];
    }
    else {
        [self taskCompleted];
    }
}

-(void)start
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTerminationNotification:)
                                                 name:NSTaskDidTerminateNotification
                                               object:task];
    
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    BOOL isDirectory;
    
    if (![fm fileExistsAtPath:[task launchPath] isDirectory:&isDirectory] || isDirectory ||
        ![fm isExecutableFileAtPath:[task launchPath]])
    {
        controller.state = LCSCommandStateFailed;
        [self invalidate];
        return;
    }
    
    [task launch];
    controller.state = LCSCommandStateRunning;
}

-(void)cancel
{
    [task terminate];
}

-(void)pause
{
    [task suspend];
    controller.state = LCSCommandStatePaused;
}

-(void)resume
{
    [task resume];
    controller.state = LCSCommandStateRunning;
}
@end
