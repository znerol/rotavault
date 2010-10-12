//
//  LCSRotavaultScheduleInstallCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 01.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultScheduleInstallCommand.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultError.h"
#import "LCSDiskInfoCommand.h"
#import "LCSMultiCommand.h"
#import "LCSLaunchctlRemoveCommand.h"
#import "LCSLaunchctlInfoCommand.h"
#import "LCSLaunchctlLoadCommand.h"
#import "LCSCommandRunner.h"
#import "NSData+Hex.h"
#import "LCSPropertyListSHA1Hash.h"

@interface LCSRotavaultScheduleInstallCommand (Internal)
-(void)invalidate;
-(void)handleError:(NSError*)error;
-(void)commandCollectionFailed:(NSNotification*)ntf;
-(void)commandCollectionCancelled:(NSNotification*)ntf;
-(void)commandCollectionInvalidated:(NSNotification*)ntf;
-(void)startGatherInformation;
-(void)completeGatherInformation:(NSNotification*)ntf;
-(void)startLaunchctRemove;
-(void)completeLaunchctlRemove:(NSNotification*)ntf;
-(void)startLaunchctInstall;
-(void)completeLaunchctlInstall:(NSNotification*)ntf;
@end

@implementation LCSRotavaultScheduleInstallCommand
@synthesize controller;
@synthesize runner;
@synthesize rvcopydLaunchPath;
@synthesize rvcopydLabel;

+(LCSRotavaultScheduleInstallCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                                 targetDevice:(NSString*)targetdev
                                                      runDate:(NSDate*)runDate
{
    return [[[LCSRotavaultScheduleInstallCommand alloc] initWithSourceDevice:sourcedev
                                                                targetDevice:targetdev
                                                                     runDate:runDate] autorelease];
}

-(id)initWithSourceDevice:(NSString*)sourcedev targetDevice:(NSString*)targetdev runDate:(NSDate*)runDate
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    activeControllers = [[LCSCommandControllerCollection alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(activeControllers);
    sourceDevice = [sourcedev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceDevice);
    targetDevice = [targetdev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetDevice);
    runAtDate = [runDate copy];
    // runAtDate is optional
    
    rvcopydLaunchPath = @"/usr/local/sbin/rvcopyd";
    rvcopydLabel = @"ch.znerol.rvcopyd";
    
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
    [sourceDevice release];
    [targetDevice release];
    [activeControllers release];
    
    [launchdPlistPath release];
    [launchdPlist release];
    [runAtDate release];
    
    [rvcopydLabel release];
    [rvcopydLaunchPath release];
    [super dealloc];
}

-(void)invalidate
{
    [activeControllers watchState:LCSCommandStateInvalidated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    controller.state = LCSCommandStateInvalidated;
}

-(void)handleError:(NSError*)error
{
    [activeControllers unwatchState:LCSCommandStateFailed];
    [activeControllers unwatchState:LCSCommandStateCancelled];
    [activeControllers unwatchState:LCSCommandStateFinished];    
    
    controller.error = error;
    controller.state = LCSCommandStateFailed;
}

-(void)commandCollectionFailed:(NSNotification*)ntf
{
    LCSCommandControllerCollection* sender = [ntf object];
    LCSCommandController* originalSender = [[ntf userInfo] objectForKey:LCSCommandControllerCollectionOriginalSenderKey];
    
    /*
     * No need to bail out if there is no launchd job installed. However we need to remove launchdInfoCtl from the
     * controller collection in order still allow firing of selectors subscribed to all LCSCommandStateFinished.
     */
    if (originalSender == launchdInfoCtl) {
        [activeControllers removeController:launchdInfoCtl];
        return;
    }
    
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

-(BOOL)validateDiskInformation
{
    NSDictionary *sourceDiskInformation = sourceInfoCtl.result;
    NSDictionary *targetDiskInformation = targetInfoCtl.result;
    NSDictionary *startupDiskInformation = startupInfoCtl.result;
    
    /* error if source device is the startup disk */
    if ([[sourceDiskInformation objectForKey:@"DeviceNode"] isEqual:[startupDiskInformation objectForKey:@"DeviceNode"]]) {
        
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Block copy operation from startup disk is not supported"));
        [self handleError:error];
        return NO;
    }
    
    /* error if source and target are the same */
    if ([sourceDiskInformation isEqual:targetDiskInformation]) {
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Source and target may not be the same"));
        [self handleError:error];
        return NO;
    }
    
    /* error if target disk is mounted */
    if (![[targetDiskInformation objectForKey:@"MountPoint"] isEqualToString:@""])
    {
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Target must not be mounted"));
        [self handleError:error];
        return NO;
    }
    
    /* error if target device is not big enough to hold contents from source */
    if ([[sourceDiskInformation objectForKey:@"TotalSize"] longLongValue] > [[targetDiskInformation objectForKey:@"TotalSize"] longLongValue]) {
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Target is too small to hold all content of source"));
        [self handleError:error];
        return NO;
    }
    
    return YES;
}

-(BOOL)constructLaunchdPlist
{
    NSDictionary *sourceDiskInformation = sourceInfoCtl.result;
    NSDictionary *targetDiskInformation = targetInfoCtl.result;
    NSString *sourceUUID = [sourceDiskInformation objectForKey:@"VolumeUUID"];
    NSString *targetSHA1 = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:targetDiskInformation] stringWithHexBytes];
    
    // FIXME: handle nil/empty values
    NSArray *args = [NSArray arrayWithObjects:rvcopydLaunchPath, @"-sourcedev", sourceDevice, @"-targetdev",
                     targetDevice, @"-sourcecheck", [NSString stringWithFormat:@"uuid:%@", sourceUUID], @"-targetcheck", 
                     [NSString stringWithFormat:@"sha1:%@", targetSHA1], rvcopydLabel, @"label", nil];
    
    NSString *runKey;
    id runValue;
    if (runAtDate) {
        runKey = @"StartCalendarInterval";
        NSDateFormatter *minFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [minFormatter setDateFormat:@"mm"];
        NSDateFormatter *hourFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [hourFormatter setDateFormat:@"HH"];
        NSDateFormatter *dayFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dayFormatter setDateFormat:@"dd"];
        NSDateFormatter *monthFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [monthFormatter setDateFormat:@"MM"];
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        [numberFormatter setAllowsFloats:NO];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        runValue = [NSDictionary dictionaryWithObjectsAndKeys:
                    [numberFormatter numberFromString:[minFormatter stringFromDate:runAtDate]], @"Minute",
                    [numberFormatter numberFromString:[hourFormatter stringFromDate:runAtDate]], @"Hour",
                    [numberFormatter numberFromString:[dayFormatter stringFromDate:runAtDate]], @"Day",
                    [numberFormatter numberFromString:[monthFormatter stringFromDate:runAtDate]], @"Month",
                    nil];
    }
    else {
        runKey = @"RunAtLoad";
        runValue = [NSNumber numberWithBool:YES];
    }
    
    launchdPlist = [[NSDictionary alloc] initWithObjectsAndKeys:
                    rvcopydLabel, @"Label",
                    args, @"ProgramArguments",
                    [NSNumber numberWithBool:YES], @"LaunchOnlyOnce",
                    runValue, runKey,
                    nil];
    return YES;
}

-(BOOL)writeLaunchdPlist
{
    const char template[] = "/tmp/launchd-plist.XXXXXXXX";
    char *tmppath = (char*)malloc(sizeof(template));
    memcpy(tmppath, template, sizeof(template));
    int tmpfd = mkstemp(tmppath);
    BOOL result = NO;
    
    if (tmpfd < 0) {
        NSString *failureReason = LCSErrorLocalizedFailureReasonFromErrno(errno);
        NSError *error = LCSERROR_METHOD(NSPOSIXErrorDomain, errno,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to create new temporary file: %@", failureReason),
                                         LCSERROR_LOCALIZED_FAILURE_REASON(failureReason));
        [self handleError:error];
        goto writeLaunchdPlist_freeAndReturn;
    }
    NSFileHandle *fh = [[NSFileHandle alloc] initWithFileDescriptor:tmpfd];
    
    launchdPlistPath = [[NSString alloc] initWithCString:tmppath encoding:NSUTF8StringEncoding];
    
    NSString *errorDescription;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:launchdPlist
                                                              format:NSPropertyListXMLFormat_v1_0
                                                    errorDescription:&errorDescription];
    
    if (data == nil) {
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSPropertyListSerializationError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to serialize launchd property list: %@", errorDescription),
                                         LCSERROR_LOCALIZED_FAILURE_REASON(errorDescription));
        [self handleError:error];
        goto writeLaunchdPlist_closeFHAndReturn;
    }
    
    [fh writeData:data];
    result = YES;
    
writeLaunchdPlist_closeFHAndReturn:
    [fh closeFile];
    [fh release];
    
writeLaunchdPlist_freeAndReturn:
    free(tmppath);
    
    return result;
}

-(void)startGatherInformation
{
    NSParameterAssert([activeControllers.controllers count] == 0);
    
    controller.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeGatherInformation:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:activeControllers];
    
    launchdInfoCtl = [runner run:[LCSLaunchctlInfoCommand commandWithLabel:rvcopydLabel]];
    launchdInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on launchd job"];
    [activeControllers addController:launchdInfoCtl];
    
    startupInfoCtl = [runner run:[LCSDiskInfoCommand commandWithDevicePath:@"/"]];
    startupInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on startup disk"];
    [activeControllers addController:startupInfoCtl];
    
    sourceInfoCtl = [runner run:[LCSDiskInfoCommand commandWithDevicePath:sourceDevice]];
    sourceInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on source device"];
    [activeControllers addController:sourceInfoCtl];
    
    targetInfoCtl = [runner run:[LCSDiskInfoCommand commandWithDevicePath:targetDevice]];
    targetInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on target device"];
    [activeControllers addController:targetInfoCtl];
}

-(void)completeGatherInformation:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                                  object:activeControllers];
    
    if (![self validateDiskInformation]) {
        return;
    }
    if (![self constructLaunchdPlist]) {
        return;
    }
    if (![self writeLaunchdPlist]) {
        return;
    }
    
    if (launchdInfoCtl.result != nil) {
        [self startLaunchctRemove];
    }
    else {
        [self startLaunchctInstall];
    }
}

-(void)startLaunchctRemove
{
    controller.progressMessage = [NSString localizedStringWithFormat:@"Removing old launchd job"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeLaunchctlRemove:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:activeControllers];
    
    LCSCommandController *ctl = [runner run:[LCSLaunchctlRemoveCommand commandWithLabel:rvcopydLabel]];
    ctl.title = [NSString localizedStringWithFormat:@"Remove old launchd job"];
    [activeControllers addController:ctl];
}

-(void)completeLaunchctlRemove:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                                  object:activeControllers];
    
    [self startLaunchctInstall];
}

-(void)startLaunchctInstall
{
    controller.progressMessage = [NSString localizedStringWithFormat:@"Installing new launchd job"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeLaunchctlInstall:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:activeControllers];
    
    LCSCommandController *ctl = [runner run:[LCSLaunchctlLoadCommand commandWithPath:launchdPlistPath]];
    ctl.title = [NSString localizedStringWithFormat:@"Install new launchd job"];
    [activeControllers addController:ctl];
}

-(void)completeLaunchctlInstall:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                                  object:activeControllers];
    
    controller.progressMessage = [NSString localizedStringWithFormat:@"Complete"];
    
    controller.state = LCSCommandStateFinished;
}

-(void)start
{
    controller.state = LCSCommandStateRunning;
    [self startGatherInformation];
}
@end
