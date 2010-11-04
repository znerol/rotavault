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
#import "LCSRotavaultFreshSystemEnvironmentCommand.h"
#import "LCSAppleRAIDListCommand.h"
#import "LCSLaunchctlLoadCommand.h"
#import "LCSRotavaultPrivilegedJobInstallCommand.h"
#import "LCSRotavaultCreateJobDictionary.h"
#import "NSData+Hex.h"
#import "LCSPropertyListSHA1Hash.h"
#import "SampleCommon.h"
#import "LCSRotavaultScheduleInstallVerifier.h"

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
    
    [systemEnvironment release];
    
    [sourceDevice release];
    [targetDevice release];
    
    [launchdPlistPath release];
    [launchdPlist release];
    [runAtDate release];
    
    [rvcopydLabel release];
    [rvcopydLaunchPath release];
    [super dealloc];
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
    
    systemEnvCommand = [LCSRotavaultFreshSystemEnvironmentCommand commandWithDefaultSystemEnvironmentObserver];
    systemEnvCommand.title = [NSString localizedStringWithFormat:@"Gather information"];
    [activeCommands addCommand:systemEnvCommand];
    [systemEnvCommand start];
}

-(void)completeGatherInformation:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                                  object:activeCommands];
    
    systemEnvironment = [systemEnvCommand.result retain];
    
    LCSRotavaultScheduleInstallVerifier *verifier =
        [LCSRotavaultScheduleInstallVerifier verifierWithMethod:method
                                                   sourceDevice:sourceDevice
                                                   targetDevice:targetDevice
                                                        runDate:runAtDate
                                              systemEnvironment:systemEnvironment];
    
    [verifier evaluate];
    
    if (!verifier.passed) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(verifier.message));
        [self handleError:err];
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
    
    /* construct parameters */
    NSDictionary* sourceDiskInformation = [systemEnvironment valueForKeyPath:
                                           [NSString stringWithFormat:@"diskinfo.byDeviceIdentifier.%@",
                                            [sourceDevice lastPathComponent]]];
    NSDictionary* targetDiskInformation = [systemEnvironment valueForKeyPath:
                                           [NSString stringWithFormat:@"diskinfo.byDeviceIdentifier.%@",
                                            [targetDevice lastPathComponent]]];    
    NSString *sourceCheck = nil;
    if ([@"asr" isEqualToString:method]) {
        sourceCheck = [NSString stringWithFormat:@"uuid:%@", [sourceDiskInformation objectForKey:@"VolumeUUID"]];
    }
    else if ([@"appleraid" isEqualToString:method]) {
        sourceCheck = [NSString stringWithFormat:@"sha1:%@",
                       [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:sourceDiskInformation] stringWithHexBytes]];
    }
    NSString *targetCheck = [NSString stringWithFormat:@"sha1:%@",
                             [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:targetDiskInformation]
                              stringWithHexBytes]];
    
    LCSCommand *ctl = nil;
    if (authorization) {
        ctl = [LCSRotavaultPrivilegedJobInstallCommand privilegedJobInstallCommandWithLabel:rvcopydLabel
                                                                                     method:method
                                                                                    runDate:runAtDate
                                                                                     source:sourceDevice
                                                                                     target:targetDevice
                                                                             sourceChecksum:sourceCheck
                                                                             targetChecksum:targetCheck
                                                                              authorization:authorization];
    }
    else {
        launchdPlist = (NSDictionary*)LCSRotavaultCreateJobDictionary((CFStringRef)rvcopydLabel,
                                                                           (CFStringRef)method,
                                                                           (CFDateRef)runAtDate,
                                                                           (CFStringRef)sourceDevice,
                                                                           (CFStringRef)targetDevice,
                                                                           (CFStringRef)sourceCheck,
                                                                           (CFStringRef)targetCheck);
        
        if (launchdPlist == nil) {
            NSError *err = LCSERROR_METHOD(NSPOSIXErrorDomain, errno,
                                           LCSERROR_LOCALIZED_DESCRIPTION(@"Unable to create the rotavault launchd job plist"));
            [self handleError:err];
            return;
        }
        
        [self writeLaunchdPlist];
        
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
