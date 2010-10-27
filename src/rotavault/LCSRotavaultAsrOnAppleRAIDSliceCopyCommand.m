//
//  LCSRotavaultAsrOnAppleRAIDSliceCopyCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 25.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultAsrOnAppleRAIDSliceCopyCommand.h"
#import "LCSInitMacros.h"
#import "LCSCommand.h"
#import "LCSDiskInfoCommand.h"
#import "LCSAppleRAIDRemoveMemberCommand.h"
#import "LCSAsrRestoreCommand.h"
#import "LCSAppleRAIDAddMemberCommand.h"
#import "LCSAppleRAIDMonitorRebuildCommand.h"
#import "LCSAppleRAIDListCommand.h"
#import "LCSRotavaultError.h"
#import "LCSPropertyListSHA1Hash.h"
#import "NSData+Hex.h"


@interface LCSRotavaultAsrOnAppleRAIDSliceCopyCommand (PrivateMethods)
-(BOOL)verifyDiskInformation:(NSDictionary*)diskinfo withChecksum:(NSString*)checksum;
-(void)startGatherInformation;
-(void)completeGatherInformation:(NSNotification*)ntf;
-(void)startRemoveSourceSliceFromRAIDSet;
-(void)completeRemoveSourceSliceFromRAIDSet:(NSNotification*)ntf;
-(void)startBlockCopy;
-(void)completeBlockCopy:(NSNotification*)ntf;
-(void)startAddSourceSliceToRAIDSet;
-(void)completeAddSourceSliceToRAIDSet:(NSNotification*)ntf;
-(void)startMonitorRebuildRAIDSet;
-(void)completeMonitorRebuildRAIDSet:(NSNotification*)ntf;
@end


@implementation LCSRotavaultAsrOnAppleRAIDSliceCopyCommand
+(LCSRotavaultAsrOnAppleRAIDSliceCopyCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                                       sourceChecksum:(NSString*)sourcecheck
                                                         targetDevice:(NSString*)targetdev
                                                       targetChecksum:(NSString*)targetcheck
{
    return [[[LCSRotavaultAsrOnAppleRAIDSliceCopyCommand alloc] initWithSourceDevice:sourcedev
                                                                      sourceChecksum:sourcecheck
                                                                        targetDevice:targetdev
                                                                      targetChecksum:targetcheck] autorelease];
}

-(id)initWithSourceDevice:(NSString*)sourcedev
           sourceChecksum:(NSString*)sourcecheck
             targetDevice:(NSString*)targetdev
           targetChecksum:(NSString*)targetcheck
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    sourceDevice = [sourcedev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceDevice);
    sourceChecksum = [sourcecheck copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceChecksum);
    targetDevice = [targetdev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetDevice);
    targetChecksum = [targetcheck copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetChecksum);
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [sourceDevice release];
    [sourceChecksum release];
    [targetDevice release];
    [targetChecksum release];
    [raidUUID release];
    [super dealloc];
}

-(BOOL)verifyDiskInformation:(NSDictionary*)diskinfo withChecksum:(NSString*)checksum
{
    NSArray* components = [checksum componentsSeparatedByString:@":"];
    
    if ([components count] != 2) {
        /* FIXME: Error Description */
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedInputReceivedError);
        [self handleError:err];
        return NO;
    }
    
    NSString* algo = [components objectAtIndex:0];
    NSString* actual = [components objectAtIndex:1];
    NSString* expected;
    
    if ([algo isEqualToString:@"sha1"]) {
        expected = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:diskinfo] stringWithHexBytes];
    }
    else if ([algo isEqualToString:@"uuid"]) {
        expected = [diskinfo objectForKey:@"VolumeUUID"];
    }
    else {
        /* FIXME: Error Description */
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedInputReceivedError);
        [self handleError:err];
        return NO;
    }
    
    if (![actual isEqualToString:expected]) {
        /* FIXME: Error Description */
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedInputReceivedError);
        [self handleError:err];
        return NO;
    }
    
    return YES;
}

-(void)startGatherInformation
{
    NSParameterAssert([activeCommands.commands count] == 0);
    
    self.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeGatherInformation:)
                                                 name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                               object:activeCommands];
    
    sourceInfoCtl = [LCSDiskInfoCommand commandWithDevicePath:sourceDevice];
    sourceInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on source device"];
    [activeCommands addCommand:sourceInfoCtl];
    [sourceInfoCtl start];
    
    targetInfoCtl = [LCSDiskInfoCommand commandWithDevicePath:targetDevice];
    targetInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on target device"];
    [activeCommands addCommand:targetInfoCtl];
    [targetInfoCtl start];
    
    raidInfoCtl = [LCSAppleRAIDListCommand command];
    raidInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on AppleRAID devices"];
    [activeCommands addCommand:raidInfoCtl];
    [raidInfoCtl start];
}

-(void)completeGatherInformation:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                                  object:activeCommands];
    
    if (![self verifyDiskInformation:sourceInfoCtl.result withChecksum:sourceChecksum]) {
        return;
    }
    if (![self verifyDiskInformation:targetInfoCtl.result withChecksum:targetChecksum]) {
        return;
    }
    /* error if any raid set in the system is not online */
    NSPredicate *checkOnline = [NSPredicate predicateWithFormat:@"RAIDSetStatus != 'Online'"];
    NSArray *nonOnlineRaidSets = [raidInfoCtl.result filteredArrayUsingPredicate:checkOnline];
    if ([nonOnlineRaidSets count] > 0) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"One or more RAID sets are not in a healthy state. Please check your system with Disk Utility"));
        [self handleError:err];
        return;
    }
    if (![[sourceInfoCtl.result objectForKey:@"RAIDSetStatus"] isEqualToString:@"Online"]) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Source raid set is not online"));
        [self handleError:err];
        return;
    }
    if (![[sourceInfoCtl.result objectForKey:@"RAIDSetLevelType"] isEqualToString:@"Mirror"]) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Source is not a mirror raid set"));
        [self handleError:err];
        return;
    }
    
    raidUUID = [[sourceInfoCtl.result objectForKey:@"RAIDSetUUID"] retain];
    if ([raidUUID length] != 36) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"UUID of raid set has wrong format"));
        [self handleError:err];
        return;
    }
    
    [self startRemoveSourceSliceFromRAIDSet];
}

-(void)startRemoveSourceSliceFromRAIDSet
{
    self.progressMessage = [NSString localizedStringWithFormat:@"Removing source slice from RAID set"];
    
    LCSCommand *ctl = [LCSAppleRAIDRemoveMemberCommand commandWithRaidUUID:raidUUID
                                                                devicePath:sourceDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeRemoveSourceSliceFromRAIDSet:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    
    ctl.title = [NSString localizedStringWithFormat:@"Remove source slice from RAID set"];
    [activeCommands addCommand:ctl];
    [ctl start];    
}

-(void)completeRemoveSourceSliceFromRAIDSet:(NSNotification*)ntf
{
    LCSCommand *ctl = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                                  object:ctl];
    
    [self startBlockCopy];
}

-(void)startBlockCopy
{
    self.progressMessage = [NSString localizedStringWithFormat:@"Performing block copy"];
    
    LCSCommand *ctl = [LCSAsrRestoreCommand commandWithSource:sourceDevice target:targetDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeBlockCopy:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    ctl.title = [NSString localizedStringWithFormat:@"Block copy"];
    [activeCommands addCommand:ctl];
    
    self.progressIndeterminate = NO;
    [ctl addObserver:self forKeyPath:@"progress" options:0 context:nil];
    
    [ctl start];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:@"progress"]) {
        self.progress = ((LCSCommand*)object).progress;
    }
}

-(void)completeBlockCopy:(NSNotification*)ntf
{
    LCSCommand* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:sender.state]
                                                  object:sender];
    [sender removeObserver:self forKeyPath:@"progress"];
    self.progressIndeterminate = YES;
    
    [self startAddSourceSliceToRAIDSet];
}

-(void)startAddSourceSliceToRAIDSet
{
    self.progressMessage = [NSString localizedStringWithFormat:@"Adding source slice back to RAID set"];
    
    LCSCommand *ctl = [LCSAppleRAIDAddMemberCommand commandWithRaidUUID:raidUUID
                                                             devicePath:sourceDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeAddSourceSliceToRAIDSet:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    
    ctl.title = [NSString localizedStringWithFormat:@"Add source slice back to RAID set"];
    [activeCommands addCommand:ctl];
    [ctl start];
}

-(void)completeAddSourceSliceToRAIDSet:(NSNotification*)ntf
{
    LCSCommand *ctl = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                                  object:ctl];
    
    [self startMonitorRebuildRAIDSet];
}

-(void)startMonitorRebuildRAIDSet
{
    self.progressMessage = [NSString localizedStringWithFormat:@"Rebuilding RAID set"];
    LCSCommand *ctl = [LCSAppleRAIDMonitorRebuildCommand commandWithRaidUUID:raidUUID
                                                                  devicePath:sourceDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeMonitorRebuildRAIDSet:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    
    ctl.title = [NSString localizedStringWithFormat:@"Rebuild RAID set"];
    [activeCommands addCommand:ctl];
    
    self.progressIndeterminate = NO;
    [ctl addObserver:self forKeyPath:@"progress" options:0 context:nil];
    
    [ctl start];
}

-(void)completeMonitorRebuildRAIDSet:(NSNotification*)ntf
{
    LCSCommand *ctl = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                                  object:ctl];
    [ctl removeObserver:self forKeyPath:@"progress"];
    self.progressIndeterminate = YES;
    
    self.progressMessage = [NSString localizedStringWithFormat:@"Complete"];
    
    self.state = LCSCommandStateFinished;
}

-(void)performStart
{
    self.state = LCSCommandStateRunning;
    [self startGatherInformation];
}

-(void)performCancel
{
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];    
}
@end
