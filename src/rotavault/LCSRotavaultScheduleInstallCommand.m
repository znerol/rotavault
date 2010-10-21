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
#import "LCSLaunchctlRemoveCommand.h"
#import "LCSLaunchctlInfoCommand.h"
#import "LCSLaunchctlLoadCommand.h"
#import "LCSRotavaultPrivilegedJobInfoCommand.h"
#import "LCSRotavaultPrivilegedJobInstallCommand.h"
#import "LCSRotavaultPrivilegedJobRemoveCommand.h"
#import "LCSRotavaultCreateJobDictionary.h"
#import "LCSCommandRunner.h"
#import "NSData+Hex.h"
#import "LCSPropertyListSHA1Hash.h"
#import "SampleCommon.h"

#import "LCSDistributedCommandStateWatcher.h"

@interface LCSRotavaultScheduleInstallCommand (Internal)
-(void)startGatherInformation;
-(void)completeGatherInformation:(NSNotification*)ntf;
-(void)startLaunchctRemove;
-(void)completeLaunchctlRemove:(NSNotification*)ntf;
-(void)startLaunchctInstall;
-(void)completeLaunchctlInstall:(NSNotification*)ntf;
@end

@implementation LCSRotavaultScheduleInstallCommand
@synthesize rvcopydLaunchPath;
@synthesize rvcopydLabel;

+(LCSRotavaultScheduleInstallCommand*)commandWithLabel:(NSString*)label
                                          sourceDevice:(NSString*)sourcedev
                                          targetDevice:(NSString*)targetdev
                                               runDate:(NSDate*)runDate
                                     withAuthorization:(AuthorizationRef)auth
{
    return [[[LCSRotavaultScheduleInstallCommand alloc] initWithLabel:(NSString*)label
                                                         sourceDevice:sourcedev
                                                         targetDevice:targetdev
                                                              runDate:runDate
                                                    withAuthorization:auth] autorelease];
}

-(id)initWithLabel:(NSString*)label
      sourceDevice:(NSString*)sourcedev
      targetDevice:(NSString*)targetdev
           runDate:(NSDate*)runDate
 withAuthorization:(AuthorizationRef)auth
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    rvcopydLabel = [label copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(rvcopydLabel);
    sourceDevice = [sourcedev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceDevice);
    targetDevice = [targetdev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetDevice);
    runAtDate = [runDate copy];
    // runAtDate is optional
    authorization = auth;
    // authorization is optional
    
    rvcopydLaunchPath = @"/usr/local/sbin/rvcopyd";
    
    return self;
}

-(void)dealloc
{
    [sourceDevice release];
    [targetDevice release];
    
    [launchdPlistPath release];
    [launchdPlist release];
    [runAtDate release];
    
    [rvcopydLabel release];
    [rvcopydLaunchPath release];
    [super dealloc];
}

-(void)commandCollectionFailed:(NSNotification*)ntf
{
    LCSCommandController* originalSender = [[ntf userInfo] objectForKey:LCSCommandControllerCollectionOriginalSenderKey];
    
    /*
     * No need to bail out if there is no launchd job installed. However we need to remove launchdInfoCtl from the
     * controller collection in order still allow firing of selectors subscribed to all LCSCommandStateFinished.
     */
    if (originalSender == launchdInfoCtl) {
        [activeControllers removeController:launchdInfoCtl];
        return;
    }
    
    [super commandCollectionFailed:ntf];
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
    
    launchdPlist = (NSDictionary*)LCSRotavaultCreateJobDictionary((CFStringRef)rvcopydLabel,
                                                                           CFSTR("asr"),
                                                                           (CFDateRef)runAtDate,
                                                                           (CFStringRef)sourceDevice,
                                                                           (CFStringRef)targetDevice,
                                                                           (CFStringRef)[NSString stringWithFormat:@"uuid:%@", sourceUUID],
                                                                           (CFStringRef)[NSString stringWithFormat:@"sha1:%@", targetSHA1]);
    return (launchdPlist != nil);
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
    
    if (authorization) {
        launchdInfoCtl = [LCSCommandController controllerWithCommand:[LCSRotavaultPrivilegedJobInfoCommand
                                                                      privilegedJobInfoCommandWithLabel:rvcopydLabel
                                                                      authorization:authorization]];
    }
    else {
        launchdInfoCtl = [LCSCommandController controllerWithCommand:[LCSLaunchctlInfoCommand commandWithLabel:rvcopydLabel]];
    }
    
    launchdInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on launchd job"];
    [activeControllers addController:launchdInfoCtl];
    [launchdInfoCtl start];
                          
    startupInfoCtl = [LCSCommandController controllerWithCommand:[LCSDiskInfoCommand commandWithDevicePath:@"/"]];
    startupInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on startup disk"];
    [activeControllers addController:startupInfoCtl];
    [startupInfoCtl start];
    
    sourceInfoCtl = [LCSCommandController controllerWithCommand:[LCSDiskInfoCommand commandWithDevicePath:sourceDevice]];
    sourceInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on source device"];
    [activeControllers addController:sourceInfoCtl];
    [sourceInfoCtl start];
    
    targetInfoCtl = [LCSCommandController controllerWithCommand:[LCSDiskInfoCommand commandWithDevicePath:targetDevice]];
    targetInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on target device"];
    [activeControllers addController:targetInfoCtl];
    [targetInfoCtl start];
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
    LCSCommandController *ctl = nil;
    if (authorization) {
        ctl = [LCSCommandController controllerWithCommand:[LCSRotavaultPrivilegedJobRemoveCommand
                                                           privilegedJobRemoveCommandWithLabel:rvcopydLabel
                                                           authorization:authorization]];
    }
    else {
        ctl = [LCSCommandController controllerWithCommand:[LCSLaunchctlRemoveCommand commandWithLabel:rvcopydLabel]];
    }
    ctl.title = [NSString localizedStringWithFormat:@"Remove old launchd job"];
    [activeControllers addController:ctl];
    [ctl start];
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
    LCSCommandController *ctl = nil;
    if (authorization) {
        NSDictionary *sourceDiskInformation = sourceInfoCtl.result;
        NSDictionary *targetDiskInformation = targetInfoCtl.result;
        NSString *sourceUUID = [sourceDiskInformation objectForKey:@"VolumeUUID"];
        NSString *targetSHA1 = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:targetDiskInformation] stringWithHexBytes];
        
        ctl = [LCSCommandController controllerWithCommand:[LCSRotavaultPrivilegedJobInstallCommand
                                                           privilegedJobInstallCommandWithLabel:rvcopydLabel
                                                           method:@"asr"
                                                           runDate:runAtDate
                                                           source:sourceDevice
                                                           target:targetDevice
                                                           sourceChecksum:[NSString stringWithFormat:@"uuid:%@", sourceUUID]
                                                           targetChecksum:[NSString stringWithFormat:@"sha1:%@", targetSHA1]
                                                           authorization:authorization]];
    }
    else {
        ctl = [LCSCommandController controllerWithCommand:[LCSLaunchctlLoadCommand commandWithPath:launchdPlistPath]];
    }
    ctl.title = [NSString localizedStringWithFormat:@"Install new launchd job"];
    [activeControllers addController:ctl];
    
    [ctl start];
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
