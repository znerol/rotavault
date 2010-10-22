//
//  LCSRotavaultAppleRAIDCopyCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 20.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultAppleRAIDCopyCommand.h"
#import "LCSInitMacros.h"
#import "LCSCommand.h"
#import "LCSDiskInfoCommand.h"
#import "LCSAppleRAIDListCommand.h"
#import "LCSAppleRAIDAddMemberCommand.h"
#import "LCSAppleRAIDRemoveMemberCommand.h"
#import "LCSAppleRAIDMonitorRebuildCommand.h"
#import "LCSDiskUnmountCommand.h"
#import "LCSRotavaultError.h"
#import "LCSPropertyListSHA1Hash.h"
#import "NSData+Hex.h"

@interface LCSRotavaultAppleRAIDCopyCommand (PrivateMethods)
-(BOOL)verifyDiskInformation:(NSDictionary*)diskinfo withChecksum:(NSString*)checksum;
-(void)startGatherInformation;
-(void)completeGatherInformation:(NSNotification*)ntf;
-(void)startAddTargetToRAIDSet;
-(void)completeAddTargetToRAIDSet:(NSNotification*)ntf;
-(void)startMonitorRebuildRAIDSet;
-(void)completeMonitorRebuildRAIDSet:(NSNotification*)ntf;
-(void)startRemoveTargetFromRAIDSet;
-(void)completeRemoveTargetFromRAIDSet:(NSNotification*)ntf;
-(void)startUnmountTarget;
-(void)completeUnmountTarget:(NSNotification*)ntf;
@end


@implementation LCSRotavaultAppleRAIDCopyCommand
+(LCSRotavaultAppleRAIDCopyCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                             sourceChecksum:(NSString*)sourcecheck
                                               targetDevice:(NSString*)targetdev
                                             targetChecksum:(NSString*)targetcheck
{
    return [[[LCSRotavaultAppleRAIDCopyCommand alloc] initWithSourceDevice:sourcedev
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
    NSParameterAssert([activeControllers.commands count] == 0);
    
    self.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeGatherInformation:)
                                                 name:[LCSCommandCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:activeControllers];
    
    sourceInfoCtl = [LCSDiskInfoCommand commandWithDevicePath:sourceDevice];
    sourceInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on source device"];
    [activeControllers addController:sourceInfoCtl];
    [sourceInfoCtl start];
    
    targetInfoCtl = [LCSDiskInfoCommand commandWithDevicePath:targetDevice];
    targetInfoCtl.title = [NSString localizedStringWithFormat:@"Get information on target device"];
    [activeControllers addController:targetInfoCtl];
    [targetInfoCtl start];
}

-(void)completeGatherInformation:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                                  object:activeControllers];
    
    if (![self verifyDiskInformation:sourceInfoCtl.result withChecksum:sourceChecksum]) {
        return;
    }
    if (![self verifyDiskInformation:targetInfoCtl.result withChecksum:targetChecksum]) {
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
    
    [self startAddTargetToRAIDSet];
}

-(void)startAddTargetToRAIDSet
{
    self.progressMessage = [NSString localizedStringWithFormat:@"Adding target to RAID set"];
    
    LCSCommand *ctl = [LCSAppleRAIDAddMemberCommand commandWithRaidUUID:raidUUID
                                                                       devicePath:targetDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeAddTargetToRAIDSet:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    
    ctl.title = [NSString localizedStringWithFormat:@"Add target to RAID set"];
    [activeControllers addController:ctl];
    [ctl start];
}

-(void)completeAddTargetToRAIDSet:(NSNotification*)ntf
{
    LCSCommand *ctl = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                                  object:ctl];
    
    [self startMonitorRebuildRAIDSet];
}

-(void)startMonitorRebuildRAIDSet
{
    self.progressMessage = [NSString localizedStringWithFormat:@"Performing block copy"];    
    LCSCommand *ctl = [LCSAppleRAIDMonitorRebuildCommand commandWithRaidUUID:raidUUID
                                                                            devicePath:targetDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeMonitorRebuildRAIDSet:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    
    ctl.title = [NSString localizedStringWithFormat:@"Block copy"];
    [activeControllers addController:ctl];
    
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

-(void)completeMonitorRebuildRAIDSet:(NSNotification*)ntf
{
    LCSCommand *ctl = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                                  object:ctl];
    [ctl removeObserver:self forKeyPath:@"progress"];
    self.progressIndeterminate = YES;
    
    [self startRemoveTargetFromRAIDSet];
}
                                 
-(void)startRemoveTargetFromRAIDSet
{
    self.progressMessage = [NSString localizedStringWithFormat:@"Removing target from RAID set"];
    
    LCSCommand *ctl = [LCSAppleRAIDRemoveMemberCommand commandWithRaidUUID:raidUUID
                                                                          devicePath:targetDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeRemoveTargetFromRAIDSet:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    
    ctl.title = [NSString localizedStringWithFormat:@"Remove target from RAID set"];
    [activeControllers addController:ctl];
    [ctl start];    
}

-(void)completeRemoveTargetFromRAIDSet:(NSNotification*)ntf
{
    LCSCommand *ctl = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                                  object:ctl];
    
    self.progressMessage = [NSString localizedStringWithFormat:@"Complete"];
    
    [self startUnmountTarget];
}    

-(void)startUnmountTarget
{
    self.progressMessage = [NSString localizedStringWithFormat:@"Unmounting target device"];
    
    LCSCommand *ctl = [LCSDiskUnmountCommand commandWithDevicePath:targetDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeUnmountTarget:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    
    ctl.title = [NSString localizedStringWithFormat:@"Unmount target device"];
    [activeControllers addController:ctl];
    [ctl start];    
}

-(void)completeUnmountTarget:(NSNotification*)ntf
{
    LCSCommand *ctl = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateFinished]
                                                  object:ctl];
    
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
