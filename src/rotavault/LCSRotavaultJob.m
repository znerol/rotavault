//
//  LCSRotavaultJob.m
//  rotavault
//
//  Created by Lorenz Schori on 21.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultJob.h"
#import "LCSInitMacros.h"
#import "LCSCommandTemp.h"
#import "LCSCommandController.h"
#import "LCSRotavaultScheduleInstallCommand.h"
#import "LCSLaunchctlInfoCommand.h"
#import "LCSLaunchctlRemoveCommand.h"
#import "LCSRotavaultPrivilegedJobInfoCommand.h"
#import "LCSRotavaultPrivilegedJobRemoveCommand.h"
#import "LCSDistributedCommandStateWatcher.h"

@interface LCSRotavaultJob (Internal)
- (void)replaceStateWatcher;
@end

@implementation LCSRotavaultJob
@synthesize label;
@synthesize runAsRoot;
@synthesize runAsRootEnabled;
@synthesize sourceDevice;
@synthesize sourceDeviceEnabled;
@synthesize blockCopyMethodIndex;
@synthesize blockCopyMethodEnabled;
@synthesize targetDevice;
@synthesize targetDeviceEnabled;
@synthesize createImageEnabled;
@synthesize attachImageEnabled;
@synthesize runDate;
@synthesize runDateEnabled;
@synthesize scheduleJobEnabled;
@synthesize startJobEnabled;
@synthesize statusMessage;
@synthesize removeJobEnabled;
@synthesize lastError;

- (id)initWithDataObject:(id)anObject keyPath:(NSString*)keyPath authorization:(AuthorizationRef)anAuth
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    if ([keyPath length] > 0 && ![keyPath hasSuffix:@"."]) {
        keyPath = [keyPath stringByAppendingString:@"."];
    }
    
    label = [[anObject valueForKeyPath:[keyPath stringByAppendingString:@"label"]] copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(label);
    
    NSArray *properties = [NSArray arrayWithObjects:@"runAsRoot", @"sourceDevice", @"blockCopyMethodIndex",
                          @"targetDevice", @"runDate", nil];
    for (NSString *propname in properties) {
        [self setValue:[anObject valueForKey:[keyPath stringByAppendingString:propname]] forKey:propname];
    }
    
    authorization = anAuth;
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(authorization);
    
    /* get information about our job from launchd */
    [self checkStatus];
    
    return self;
}

- (void)saveToDataObject:(id)anObject keyPath:(NSString*)keyPath
{
    if ([keyPath length] > 0 && ![keyPath hasSuffix:@"."]) {
        keyPath = [keyPath stringByAppendingString:@"."];
    }
    
    NSArray *properties = [NSArray arrayWithObjects:@"label", @"runAsRoot", @"sourceDevice", @"blockCopyMethodIndex",
                          @"targetDevice", @"runDate", nil];
    for (NSString *propname in properties) {
        [anObject setValue:[self valueForKey:propname]
                forKeyPath:[keyPath stringByAppendingString:propname]];
    }
}

- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [currentCommand release];
    [backgroundCommand release];
    
    [label release];
    [sourceDevice release];
    [targetDevice release];
    [runDate release];
    
    [super dealloc];
}

- (void)updateControls
{
    self.runAsRootEnabled =         !currentCommand && !jobScheduled;
    self.sourceDeviceEnabled =      !currentCommand && !jobScheduled;
    self.blockCopyMethodEnabled =   !currentCommand && !jobScheduled;
    self.targetDeviceEnabled =      !currentCommand && !jobScheduled;
    /* not implemented yet
    self.createImageEnabled =       !currentCommand && !jobScheduled;
    self.attachImageEnabled =       !currentCommand && !jobScheduled;
     */
    self.runDateEnabled =           !currentCommand && !jobScheduled;
    self.scheduleJobEnabled =       !currentCommand && !jobScheduled;
    self.startJobEnabled =          !currentCommand && !jobScheduled;
    self.removeJobEnabled =         !currentCommand &&  jobScheduled;
    
    if (jobRunning) {
        self.statusMessage = [NSString localizedStringWithFormat:@"This rotavault job is currently running"];
    }
    else if (jobScheduled) {
        self.statusMessage = [NSString localizedStringWithFormat:@"This rotavault job is scheduled for later execution"];
    }
    else {
        self.statusMessage = [NSString localizedStringWithFormat:@"This rotavault job is neither running nor scheduled"];
    }
}

- (void)controllerFailed:(NSNotification*)ntf
{
    LCSCommandController *ctl = [ntf object];
    self.lastError = ctl.error;
}

- (void)scheduleJob
{
    if (!scheduleJobEnabled) {
        return;
    }
    
    if (currentCommand != nil) {
        return;
    }
    
    currentCommand = [LCSCommandController controllerWithCommand:[LCSRotavaultScheduleInstallCommand
                                                                  commandWithLabel:label
                                                                  method:(blockCopyMethodIndex ? @"appleraid" : @"asr")
                                                                  sourceDevice:sourceDevice
                                                                  targetDevice:targetDevice
                                                                  runDate:runDate
                                                                  withAuthorization:(runAsRoot ? authorization : nil)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateScheduleJob:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:currentCommand];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:currentCommand];
    currentCommand.title = [NSString localizedStringWithFormat:@"Scheduling rotavault job for later execution"];
    
    [currentCommand retain];
    [currentCommand start];
    [self updateControls];
}

- (void)invalidateScheduleJob:(NSNotification*)ntf
{
    assert(currentCommand == [ntf object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:currentCommand];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                                  object:currentCommand];
    
    [currentCommand performSelector:@selector(release) withObject:nil afterDelay:0];
    currentCommand = nil;
    
    [self checkStatus];
}

- (void)startJob
{
    if (!startJobEnabled) {
        return;
    }
    
    if (currentCommand != nil) {
        return;
    }
    
    currentCommand = [LCSCommandController controllerWithCommand:[LCSRotavaultScheduleInstallCommand
                                                                  commandWithLabel:label
                                                                  method:(blockCopyMethodIndex ? @"appleraid" : @"asr")
                                                                  sourceDevice:sourceDevice
                                                                  targetDevice:targetDevice
                                                                  runDate:nil
                                                                  withAuthorization:(runAsRoot ? authorization : nil)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateStartJob:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:currentCommand];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:currentCommand];
    currentCommand.title = [NSString localizedStringWithFormat:@"Preparing rotavault job"];
    
    [currentCommand retain];
    [currentCommand start];
    [self updateControls];    
}

- (void)invalidateStartJob:(NSNotification*)ntf
{
    assert(currentCommand == [ntf object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:currentCommand];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                                  object:currentCommand];
    
    [currentCommand performSelector:@selector(release) withObject:nil afterDelay:0];
    currentCommand = nil;
    
    [self checkStatus];
}

- (void)removeJob
{
    if (!removeJobEnabled) {
        return;
    }
    
    if (currentCommand != nil) {
        /* don't run more than one command on a single job */
        return;
    }
    
    <LCSCommandTemp> removeCommand = nil;
    if (runAsRoot) {
        removeCommand = [LCSRotavaultPrivilegedJobRemoveCommand privilegedJobRemoveCommandWithLabel:label
                                                                                    authorization:authorization];
    }
    else {
        removeCommand = [LCSLaunchctlRemoveCommand commandWithLabel:label];
    }
    
    currentCommand = [LCSCommandController controllerWithCommand:removeCommand];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateRemoveJob:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:currentCommand];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:currentCommand];
    currentCommand.title = [NSString localizedStringWithFormat:@"Removing rotavault job"];
    
    [currentCommand retain];
    [currentCommand start];
    [self updateControls];    
}

- (void)invalidateRemoveJob:(NSNotification*)ntf
{
    assert(currentCommand == [ntf object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:currentCommand];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                                  object:currentCommand];
    
    [currentCommand performSelector:@selector(release) withObject:nil afterDelay:0];
    currentCommand = nil;
    
    [self checkStatus];
}

- (void)checkStatus
{
    if (currentCommand != nil) {
        /* don't run more than one command on a single job */
        return;
    }
    
    <LCSCommandTemp> infoCommand = nil;
    if (runAsRoot) {
        infoCommand = [LCSRotavaultPrivilegedJobInfoCommand privilegedJobInfoCommandWithLabel:label
                                                                                authorization:authorization];
    }
    else {
        infoCommand = [LCSLaunchctlInfoCommand commandWithLabel:label];
    }

    currentCommand = [LCSCommandController controllerWithCommand:infoCommand];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateCheckStatus:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:currentCommand];
    currentCommand.title = [NSString localizedStringWithFormat:@"Checking job status"];
    
    [currentCommand retain];
    [currentCommand start];
    [self updateControls];
}

- (void)invalidateCheckStatus:(NSNotification*)ntf
{
    assert(currentCommand == [ntf object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:currentCommand];
    
    jobScheduled = (currentCommand.exitState == LCSCommandStateFinished);
    jobRunning = jobScheduled && ([currentCommand.result objectForKey:@"PID"] != nil);
    [currentCommand performSelector:@selector(release) withObject:nil afterDelay:0];
    currentCommand = nil;
    
    if (!backgroundCommand) {
        [self replaceStateWatcher];
    }
    
    [self updateControls];
}

- (void)replaceStateWatcher
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:backgroundCommand];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                                  object:currentCommand];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateLeft:LCSCommandStateInit]
                                                  object:backgroundCommand];
    [backgroundCommand performSelector:@selector(release) withObject:nil afterDelay:0];
    
    
    backgroundCommand =
        [LCSCommandController controllerWithCommand:[LCSDistributedCommandStateWatcher commandWithLabel:label]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateStateWatcher:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:backgroundCommand];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:backgroundCommand];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startedStateWatcher:)
                                                 name:[LCSCommandController notificationNameStateLeft:LCSCommandStateInit]
                                               object:backgroundCommand];
    [backgroundCommand retain];
    
    /* forbidden under normal circumstances :) */
    [backgroundCommand.command start];
}

- (void)startedStateWatcher:(NSNotification*)ntf
{
    assert(backgroundCommand == [ntf object]);
    
    [self checkStatus];
}

- (void)invalidateStateWatcher:(NSNotification*)ntf
{
    assert(backgroundCommand == [ntf object]);
    
    [self replaceStateWatcher];
    
    [self checkStatus];
}
@end
