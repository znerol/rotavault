//
//  LCSRotavaultBlockCopyCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 06.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultBlockCopyCommand.h"
#import "LCSInitMacros.h"
#import "LCSCommandController.h"
#import "LCSDiskInfoCommand.h"
#import "LCSAsrRestoreCommand.h"
#import "LCSDiskMountCommand.h"
#import "LCSRotavaultError.h"
#import "LCSPropertyListSHA1Hash.h"
#import "NSData+Hex.h"

@interface LCSRotavaultBlockCopyCommand (PrivateMethods)
-(void)invalidate;
-(void)handleError:(NSError*)error;
-(void)commandFailed:(NSNotification*)ntf;
-(void)commandCancelled:(NSNotification*)ntf;
-(BOOL)verifyDiskInformation:(NSDictionary*)diskinfo withChecksum:(NSString*)checksum;
-(void)startGatherInformation;
-(void)partialGatherInformation:(NSNotification*)ntf;
-(void)completeGatherInformation;
-(void)startBlockCopy;
-(void)completeBlockCopy:(NSNotification*)ntf;
-(void)startSourceRemountAndInvalidate;
-(void)completeSourceRemountAndInvalidate:(NSNotification*)ntf;
@end


@implementation LCSRotavaultBlockCopyCommand
@synthesize controller;
@synthesize runner;

+(LCSRotavaultBlockCopyCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                         sourceChecksum:(NSString*)sourcecheck
                                           targetDevice:(NSString*)targetdev
                                         targetChecksum:(NSString*)targetcheck
{
    return [[[LCSRotavaultBlockCopyCommand alloc] initWithSourceDevice:sourcedev
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
    
    activeControllers = [[NSMutableArray alloc] initWithCapacity:4];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(activeControllers);
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
    [activeControllers release];
    [sourceDiskInformation release];
    [targetDiskInformation release];
    
    [sourceDevice release];
    [sourceChecksum release];
    [targetDevice release];
    [targetChecksum release];
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
    
    for (LCSCommandController *ctl in activeControllers) {
        [ctl cancel];
    }

    if (needsSourceRemount) {
        [self startSourceRemountAndInvalidate];
    }
    else {
        [self invalidate];
    }
}

-(void)commandFailed:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    [activeControllers removeObject:sender];
    
    [self handleError:sender.error];
}

-(void)commandCancelled:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    [activeControllers removeObject:sender];
    
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];
}

-(BOOL)verifyDiskInformation:(NSDictionary*)diskinfo withChecksum:(NSString*)checksum
{
    NSArray* components = [checksum componentsSeparatedByString:@":"];
    
    if ([components count] != 2) {
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
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedInputReceivedError);
        [self handleError:err];
        return NO;
    }
    
    if (![actual isEqualToString:expected]) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedInputReceivedError);
        [self handleError:err];
        return NO;
    }
    
    return YES;
}

-(void)startGatherInformation
{
    NSParameterAssert([activeControllers count] == 0);
    
    controller.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    
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
    if (![self verifyDiskInformation:sourceDiskInformation withChecksum:sourceChecksum]) {
        return;
    }
    if (![self verifyDiskInformation:targetDiskInformation withChecksum:targetChecksum]) {
        return;
    }
    
    [self startBlockCopy];
}

-(void)startBlockCopy
{
    controller.progressMessage = [NSString localizedStringWithFormat:@"Performing block copy"];
    
    needsSourceRemount = YES;
    LCSCommandController *ctl = [runner run:[LCSAsrRestoreCommand commandWithSource:sourceDevice target:targetDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandFailed:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:ctl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandCancelled:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateCancelled]
                                               object:ctl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeBlockCopy:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    ctl.title = [NSString localizedStringWithFormat:@"Block copy"];
    [activeControllers addObject:ctl];
}

-(void)completeBlockCopy:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    
    needsSourceRemount = NO;
    
    controller.progressMessage = [NSString localizedStringWithFormat:@"Complete"];
    
    [activeControllers removeObject:sender];
    
    controller.state = LCSCommandStateFinished;
    [self invalidate];
}

-(void)startSourceRemountAndInvalidate
{
    controller.progressMessage = [NSString localizedStringWithFormat:@"Remounting source device"];
    
    LCSCommandController *ctl = [runner run:[LCSDiskMountCommand commandWithDevicePath:sourceDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeSourceRemountAndInvalidate:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:ctl];
    ctl.title = [NSString localizedStringWithFormat:@"Remount source device"];
    [activeControllers addObject:ctl];
}

-(void)completeSourceRemountAndInvalidate:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    [activeControllers removeObject:sender];
    [self invalidate];
}

-(void)start
{
    controller.state = LCSCommandStateRunning;
    [self startGatherInformation];
}

-(void)cancel
{
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];    
}
@end
