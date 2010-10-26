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
#import "LCSLaunchctlLoadCommand.h"
#import "LCSRotavaultPrivilegedJobInstallCommand.h"
#import "LCSRotavaultCreateJobDictionary.h"
#import "NSData+Hex.h"
#import "LCSPropertyListSHA1Hash.h"
#import "SampleCommon.h"

#import "LCSDistributedCommandStateWatcher.h"

@interface LCSRotavaultScheduleInstallCommand (Internal)
-(void)startGatherInformation;
-(void)completeGatherInformation:(NSNotification*)ntf;
-(void)startLaunchctInstall;
-(void)completeLaunchctlInstall:(NSNotification*)ntf;
@end

@implementation LCSRotavaultScheduleInstallCommand
@synthesize rvcopydLaunchPath;

+(LCSRotavaultScheduleInstallCommand*)commandWithLabel:(NSString*)label
                                                method:(NSString*)bcmethod
                                          sourceDevice:(NSString*)sourcedev
                                          targetDevice:(NSString*)targetdev
                                               runDate:(NSDate*)runDate
                                     withAuthorization:(AuthorizationRef)auth
{
    return [[[LCSRotavaultScheduleInstallCommand alloc] initWithLabel:(NSString*)label
                                                               method:(NSString*)bcmethod
                                                         sourceDevice:sourcedev
                                                         targetDevice:targetdev
                                                              runDate:runDate
                                                    withAuthorization:auth] autorelease];
}

-(id)initWithLabel:(NSString*)label
            method:(NSString*)bcmethod
      sourceDevice:(NSString*)sourcedev
      targetDevice:(NSString*)targetdev
           runDate:(NSDate*)runDate
 withAuthorization:(AuthorizationRef)auth
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    rvcopydLabel = [label copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(rvcopydLabel);
    method = [bcmethod copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL([@"asr" isEqualToString:bcmethod] || [@"appleraid" isEqualToString:bcmethod]);
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [sourceDevice release];
    [targetDevice release];
    
    [launchdPlistPath release];
    [launchdPlist release];
    [runAtDate release];
    
    [rvcopydLabel release];
    [rvcopydLaunchPath release];
    [super dealloc];
}

-(BOOL)validateDiskInformation
{
    NSDictionary *sourceDiskInformation = sourceInfoCtl.result;
    NSDictionary *targetDiskInformation = targetInfoCtl.result;
    NSDictionary *startupDiskInformation = startupInfoCtl.result;
    
    /* error if source device is the startup disk (only holds for asr) */
    if ([@"asr" isEqualToString:method] && [[sourceDiskInformation objectForKey:@"DeviceNode"] isEqual:
         [startupDiskInformation objectForKey:@"DeviceNode"]]) {
        
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Block copy operation from startup disk is not supported"));
        [self handleError:err];
        return NO;
    }
    
    /* error if source and target are the same */
    if ([sourceDiskInformation isEqual:targetDiskInformation]) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Source and target may not be the same"));
        [self handleError:err];
        return NO;
    }
    
    /* error if target disk is mounted */
    if (![[targetDiskInformation objectForKey:@"MountPoint"] isEqualToString:@""])
    {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Target must not be mounted"));
        [self handleError:err];
        return NO;
    }
    
    /* error if target device is not big enough to hold contents from source */
    if ([[sourceDiskInformation objectForKey:@"TotalSize"] longLongValue] > [[targetDiskInformation objectForKey:@"TotalSize"] longLongValue]) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Target is too small to hold all content of source"));
        [self handleError:err];
        return NO;
    }
    
    /* error if source device is not a raid-master (this only holds for appleraid) */
    if ([@"appleraid" isEqualToString:method] && ![[sourceDiskInformation objectForKey:@"RAIDSlice"] isEqual:
                                                     [NSNumber numberWithBool:YES]]) {
        
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Source device is not a raid slice"));
        [self handleError:err];
        return NO;
    }
    
    /* error if source device is not a raid-1 (this only holds for appleraid) */
    if ([@"appleraid" isEqualToString:method] && ![[sourceDiskInformation objectForKey:@"RAIDSetLevelType"] isEqual:
                                                     @"Mirror"]) {
        
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Source device is not raid mirror"));
        [self handleError:err];
        return NO;
    }
    
    /* error if source device is not a raid-1 (this only holds for appleraid) */
    if ([@"appleraid" isEqualToString:method] && ![[sourceDiskInformation objectForKey:@"RAIDSetStatus"] isEqual:
                                                     @"Online"]) {
        
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Source raid is not online"));
        [self handleError:err];
        return NO;
    }
    return YES;
}

-(BOOL)constructLaunchdPlist
{
    NSDictionary *sourceDiskInformation = sourceInfoCtl.result;
    NSDictionary *targetDiskInformation = targetInfoCtl.result;
    NSString *sourceCheck = nil;
    if ([@"asr" isEqualToString:method]) {
        sourceCheck = [NSString stringWithFormat:@"uuid:%@", [sourceDiskInformation objectForKey:@"VolumeUUID"]];
    }
    else if ([@"appleraid" isEqualToString:method]) {
        sourceCheck = [NSString stringWithFormat:@"sha1:%@",
                       [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:sourceDiskInformation] stringWithHexBytes]];
    }
    NSString *targetSHA1 = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:targetDiskInformation] stringWithHexBytes];
    
    launchdPlist = (NSDictionary*)LCSRotavaultCreateJobDictionary((CFStringRef)rvcopydLabel,
                                                                           (CFStringRef)method,
                                                                           (CFDateRef)runAtDate,
                                                                           (CFStringRef)sourceDevice,
                                                                           (CFStringRef)targetDevice,
                                                                           (CFStringRef)sourceCheck,
                                                                           (CFStringRef)[NSString stringWithFormat:@"sha1:%@", targetSHA1]);
    return (launchdPlist != nil);
}

-(BOOL)writeLaunchdPlist
{
    const char template[] = "/tmp/launchd-plist.XXXXXXXX";
    char *tmppath = (char*)malloc(sizeof(template));
    memcpy(tmppath, template, sizeof(template));
    int tmpfd = mkstemp(tmppath);
    BOOL res = NO;
    
    if (tmpfd < 0) {
        NSString *failureReason = LCSErrorLocalizedFailureReasonFromErrno(errno);
        NSError *err = LCSERROR_METHOD(NSPOSIXErrorDomain, errno,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to create new temporary file: %@", failureReason),
                                         LCSERROR_LOCALIZED_FAILURE_REASON(failureReason));
        [self handleError:err];
        goto writeLaunchdPlist_freeAndReturn;
    }
    NSFileHandle *fh = [[NSFileHandle alloc] initWithFileDescriptor:tmpfd];
    
    launchdPlistPath = [[NSString alloc] initWithCString:tmppath encoding:NSUTF8StringEncoding];
    
    NSString *errorDescription;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:launchdPlist
                                                              format:NSPropertyListXMLFormat_v1_0
                                                    errorDescription:&errorDescription];
    
    if (data == nil) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSPropertyListSerializationError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to serialize launchd property list: %@", errorDescription),
                                       LCSERROR_LOCALIZED_FAILURE_REASON(errorDescription));
        [self handleError:err];
        goto writeLaunchdPlist_closeFHAndReturn;
    }
    
    [fh writeData:data];
    res = YES;
    
writeLaunchdPlist_closeFHAndReturn:
    [fh closeFile];
    [fh release];
    
writeLaunchdPlist_freeAndReturn:
    free(tmppath);
    
    return res;
}

-(void)startGatherInformation
{
    NSParameterAssert([activeCommands.commands count] == 0);
    
    self.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeGatherInformation:)
                                                 name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                               object:activeCommands];
    
    startupInfoCtl = [LCSDiskInfoCommand commandWithDevicePath:@"/"];
    startupInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on startup disk"];
    [activeCommands addCommand:startupInfoCtl];
    [startupInfoCtl start];
    
    sourceInfoCtl = [LCSDiskInfoCommand commandWithDevicePath:sourceDevice];
    sourceInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on source device"];
    [activeCommands addCommand:sourceInfoCtl];
    [sourceInfoCtl start];
    
    targetInfoCtl = [LCSDiskInfoCommand commandWithDevicePath:targetDevice];
    targetInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on target device"];
    [activeCommands addCommand:targetInfoCtl];
    [targetInfoCtl start];
}

-(void)completeGatherInformation:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                                  object:activeCommands];
    
    if (![self validateDiskInformation]) {
        return;
    }
    
    [self startLaunchctInstall];
}

-(void)startLaunchctInstall
{
    self.progressMessage = [NSString localizedStringWithFormat:@"Installing new launchd job"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeLaunchctlInstall:)
                                                 name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                               object:activeCommands];
    LCSCommand *ctl = nil;
    if (authorization) {
        NSDictionary *sourceDiskInformation = sourceInfoCtl.result;
        NSDictionary *targetDiskInformation = targetInfoCtl.result;
        NSString *sourceUUID = [sourceDiskInformation objectForKey:@"VolumeUUID"];
        NSString *targetSHA1 = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:targetDiskInformation] stringWithHexBytes];
        
        ctl = [LCSRotavaultPrivilegedJobInstallCommand privilegedJobInstallCommandWithLabel:rvcopydLabel
                                                                                     method:method
                                                                                    runDate:runAtDate
                                                                                     source:sourceDevice
                                                                                     target:targetDevice
                                                                             sourceChecksum:[NSString stringWithFormat:@"uuid:%@", sourceUUID]
                                                                             targetChecksum:[NSString stringWithFormat:@"sha1:%@", targetSHA1]
                                                                              authorization:authorization];
    }
    else {
        if (![self constructLaunchdPlist] || ![self writeLaunchdPlist]) {
            return;
        }
        ctl = [LCSLaunchctlLoadCommand commandWithPath:launchdPlistPath];
    }
    ctl.title = [NSString localizedStringWithFormat:@"Install new launchd job"];
    [activeCommands addCommand:ctl];
    
    [ctl start];
}

-(void)completeLaunchctlInstall:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                                  object:activeCommands];
    
    self.progressMessage = [NSString localizedStringWithFormat:@"Complete"];
    
    if (launchdPlistPath) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        [fm removeItemAtPath:launchdPlistPath error:nil];
        [fm release];
    }
    
    self.state = LCSCommandStateFinished;
}

-(void)performStart
{
    self.state = LCSCommandStateRunning;
    [self startGatherInformation];
}
@end
