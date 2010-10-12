//
//  LCSRotavaultAllDiskInformationCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 11.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <glob.h>
#import "LCSAllDiskInfoCommand.h"
#import "LCSRotavaultError.h"
#import "LCSInitMacros.h"
#import "LCSDiskInfoCommand.h"
#import "LCSCommandRunner.h"

@interface LCSAllDiskInfoCommand (PrivateMethods)
-(void)invalidate;
-(void)handleError:(NSError*)error;
-(void)commandCollectionFailed:(NSNotification*)ntf;
-(void)commandCollectionCancelled:(NSNotification*)ntf;
-(void)commandCollectionInvalidated:(NSNotification*)ntf;
-(void)startGatherInformation;
-(void)completeGatherInformation:(NSNotification*)ntf;
@end

@implementation LCSAllDiskInfoCommand
@synthesize controller;
@synthesize runner;

+ (LCSAllDiskInfoCommand*)command
{
    return [[[LCSAllDiskInfoCommand alloc] init] autorelease];
}

- (id)init
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

- (void)dealloc
{
    [activeControllers release];
    [super dealloc];
}

- (void)invalidate
{
    [activeControllers watchState:LCSCommandStateInvalidated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    controller.state = LCSCommandStateInvalidated;
}

- (void)handleError:(NSError*)error
{
    [activeControllers unwatchState:LCSCommandStateFailed];
    [activeControllers unwatchState:LCSCommandStateCancelled];
    [activeControllers unwatchState:LCSCommandStateFinished];
    
    controller.error = error;
    controller.state = LCSCommandStateFailed;
    
    for (LCSCommandController *ctl in activeControllers.controllers) {
        [ctl cancel];
    }
}

- (void)commandCollectionFailed:(NSNotification*)ntf
{
    LCSCommandControllerCollection* sender = [ntf object];
    LCSCommandController* originalSender = [[ntf userInfo] objectForKey:LCSCommandControllerCollectionOriginalSenderKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFailed]
                                                  object:sender];
    [self handleError:originalSender.error];
}

- (void)commandCollectionCancelled:(NSNotification*)ntf
{
    LCSCommandControllerCollection* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateCancelled]
                                                  object:sender];
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];
}

- (void)commandCollectionInvalidated:(NSNotification*)ntf
{
    [self invalidate];    
}

- (void)startGatherInformation
{
    NSParameterAssert([activeControllers.controllers count] == 0);
    
    glob_t g;
    int err = glob("/dev/disk*", GLOB_NOSORT, NULL, &g);
    
    /* iterate thru disks */
    if (err != 0) {
        NSString *reason = LCSErrorLocalizedFailureReasonFromErrno(errno);
        NSError *error = LCSERROR_METHOD(NSPOSIXErrorDomain, errno,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Unable to get list of disk device nodes: %@", reason),
                                         LCSERROR_LOCALIZED_DESCRIPTION(reason));
        globfree(&g);
        [self handleError:error];
        return;
    }

    controller.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeGatherInformation:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:activeControllers];
    
    for (char **devpath = g.gl_pathv; *devpath != NULL; devpath++) {
        LCSCommandController *ctl = [runner run:[LCSDiskInfoCommand commandWithDevicePath:
                                                 [NSString stringWithCString:*devpath encoding:NSUTF8StringEncoding]]];
        ctl.title = [NSString localizedStringWithFormat:@"Get information on device %s", *devpath];
        [activeControllers addController:ctl];
    }
    
    globfree(&g);
}

- (void)completeGatherInformation:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                                  object:activeControllers];
    
    NSArray *entries = [[activeControllers valueForKeyPath:@"controllers.result"] allObjects];
    NSArray *devnodes = [entries valueForKey:@"DeviceNode"];
    
    controller.result = [[NSDictionary alloc] initWithObjects:entries forKeys:devnodes];
    controller.state = LCSCommandStateFinished;
}

- (void)start
{
    controller.state = LCSCommandStateRunning;
    [self startGatherInformation];
}

- (void)cancel
{
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];    
}

@end
