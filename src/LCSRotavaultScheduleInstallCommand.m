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
-(void)commandFailed:(NSNotification*)ntf;
-(void)commandCancelled:(NSNotification*)ntf;
-(void)startGatherInformation;
-(void)partialGatherInformation:(NSNotification*)ntf;
-(void)completeGatherInformation;
-(void)startLaunchctRemove;
-(void)completeLaunchctlRemove:(NSNotification*)ntf;
-(void)startLaunchctInstall;
-(void)completeLaunchctlInstall:(NSNotification*)ntf;
@end

@implementation LCSRotavaultScheduleInstallCommand
@synthesize controller;
@synthesize runner;
@synthesize rvcopydLaunchPath;

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
    
    activeControllers = [[NSMutableArray alloc] initWithCapacity:4];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(activeControllers);
    sourceDevice = [sourcedev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceDevice);
    targetDevice = [targetdev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetDevice);
    runAtDate = [runDate copy];
    // runAtDate is optional
    
    rvcopydLaunchPath = @"/usr/local/sbin/rvcopyd";
    return self;
}

-(void)dealloc
{
    [sourceDevice release];
    [targetDevice release];
    [activeControllers release];
    
    [startupDiskInformation release];
    [sourceDiskInformation release];
    [targetDiskInformation release];
    
    [launchdPlistPath release];
    [launchdPlist release];
    [runAtDate release];
    
    [super dealloc];
}

-(void)invalidate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    controller.state = LCSCommandStateInvalidated;
}

-(void)handleError:(NSError*)error
{
    controller.error = error;
    controller.state = LCSCommandStateFailed;
    
    [self invalidate];
}

-(void)commandFailed:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    [activeControllers removeObject:sender];
    
    for (LCSCommandController *ctl in activeControllers) {
        [ctl cancel];
    }
    
    [self handleError:sender.error];
}

-(void)commandCancelled:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    [activeControllers removeObject:sender];
    
    for (LCSCommandController *ctl in activeControllers) {
        [ctl cancel];
    }
    
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];
}

-(BOOL)validateDiskInformation
{
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
    NSString *sourceUUID = [sourceDiskInformation objectForKey:@"VolumeUUID"];
    NSString *targetSHA1 = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:targetDiskInformation] stringWithHexBytes];
    
    // FIXME: handle nil/empty values
    NSArray *args = [NSArray arrayWithObjects:rvcopydLaunchPath, @"-sourcedev", sourceDevice, @"-targetdev",
                     targetDevice, @"-sourcecheck", [NSString stringWithFormat:@"uuid:%@", sourceUUID], @"-targetcheck", 
                     [NSString stringWithFormat:@"sha1:%@", targetSHA1], nil];
    
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
                    @"ch.znerol.rvcopyd", @"Label",
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
    NSParameterAssert([activeControllers count] == 0);
    
    controller.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    
    LCSCommandController *launchdInfoCtl = [runner run:[LCSLaunchctlInfoCommand commandWithLabel:@"ch.znerol.rvcopyd"]];
    /* We want to continue even if the command failed (because no job is known to launchd with this label) */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(partialGatherInformation:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:launchdInfoCtl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCancelled:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateCancelled]
                                               object:launchdInfoCtl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(partialGatherInformation:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                               object:launchdInfoCtl];
    launchdInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on launchd job"];
    launchdInfoCtl.userInfo = @"launchctlInfo";
    [activeControllers addObject:launchdInfoCtl];
    
    LCSCommandController *sysdiskInfoCtl = [runner run:[LCSDiskInfoCommand commandWithDevicePath:@"/"]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:sysdiskInfoCtl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCancelled:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateCancelled]
                                               object:sysdiskInfoCtl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(partialGatherInformation:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                               object:sysdiskInfoCtl];
    sysdiskInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on startup disk"];
    sysdiskInfoCtl.userInfo = @"startupDiskInformation";
    [activeControllers addObject:sysdiskInfoCtl];
    
    LCSCommandController *sourceInfoCtl = [runner run:[LCSDiskInfoCommand commandWithDevicePath:sourceDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:sourceInfoCtl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCancelled:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateCancelled]
                                               object:sourceInfoCtl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(partialGatherInformation:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                               object:sourceInfoCtl];
    sourceInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on source device"];
    sourceInfoCtl.userInfo = @"sourceDiskInformation";
    [activeControllers addObject:sourceInfoCtl];
    
    LCSCommandController *targetInfoCtl = [runner run:[LCSDiskInfoCommand commandWithDevicePath:targetDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:targetInfoCtl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCancelled:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateCancelled]
                                               object:targetInfoCtl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(partialGatherInformation:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                               object:targetInfoCtl];
    targetInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on target device"];
    targetInfoCtl.userInfo = @"targetDiskInformation";
    [activeControllers addObject:targetInfoCtl];
}

-(void)partialGatherInformation:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    
    [self setValue:sender.result forKey:sender.userInfo];
    
    [activeControllers removeObject:sender];
    if ([activeControllers count] == 0) {
        [self completeGatherInformation];
    }
}

-(void)completeGatherInformation
{
    if (![self validateDiskInformation]) {
        return;
    }
    if (![self constructLaunchdPlist]) {
        return;
    }
    if (![self writeLaunchdPlist]) {
        return;
    }
    
    if (launchctlInfo != nil) {
        [self startLaunchctRemove];
    }
    else {
        [self startLaunchctInstall];
    }
}

-(void)startLaunchctRemove
{
    controller.progressMessage = [NSString localizedStringWithFormat:@"Removing old launchd job"];
    
    LCSCommandController *ctl = [runner run:[LCSLaunchctlRemoveCommand commandWithLabel:@"ch.znerol.rvcopyd"]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:ctl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCancelled:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateCancelled]
                                               object:ctl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeLaunchctlRemove:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    ctl.title = [NSString localizedStringWithFormat:@"Remove old launchd job"];
    [activeControllers addObject:ctl];
}

-(void)completeLaunchctlRemove:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    
    [activeControllers removeObject:sender];
    [self startLaunchctInstall];
}

-(void)startLaunchctInstall
{
    controller.progressMessage = [NSString localizedStringWithFormat:@"Installing new launchd job"];
    
    LCSCommandController *ctl = [runner run:[LCSLaunchctlLoadCommand commandWithPath:launchdPlistPath]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:ctl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCancelled:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateCancelled]
                                               object:ctl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeLaunchctlInstall:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    ctl.title = [NSString localizedStringWithFormat:@"Install new launchd job"];
    [activeControllers addObject:ctl];
}

-(void)completeLaunchctlInstall:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    
    controller.progressMessage = [NSString localizedStringWithFormat:@"Complete"];
    
    [activeControllers removeObject:sender];
    
    controller.state = LCSCommandStateFinished;
    [self invalidate];
}

-(void)start
{
    controller.state = LCSCommandStateRunning;
    [self startGatherInformation];
}
@end
