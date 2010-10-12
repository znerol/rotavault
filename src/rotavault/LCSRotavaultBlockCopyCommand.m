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
-(void)commandCollectionFailed:(NSNotification*)ntf;
-(void)commandCollectionCancelled:(NSNotification*)ntf;
-(void)commandCollectionInvalidated:(NSNotification*)ntf;
-(BOOL)verifyDiskInformation:(NSDictionary*)diskinfo withChecksum:(NSString*)checksum;
-(void)startGatherInformation;
-(void)completeGatherInformation:(NSNotification*)ntf;
-(void)startBlockCopy;
-(void)completeBlockCopy:(NSNotification*)ntf;
-(void)startSourceRemount;
-(void)completeSourceRemount:(NSNotification*)ntf;
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
    
    activeControllers = [[LCSCommandControllerCollection alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(activeControllers);
    sourceDevice = [sourcedev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceDevice);
    sourceChecksum = [sourcecheck copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceChecksum);
    targetDevice = [targetdev copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetDevice);
    targetChecksum = [targetcheck copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetChecksum);

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
    [activeControllers release];
    [sourceDevice release];
    [sourceChecksum release];
    [targetDevice release];
    [targetChecksum release];
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
    
    for (LCSCommandController *ctl in activeControllers.controllers) {
        [ctl cancel];
    }

    if (needsSourceRemount) {
        [self startSourceRemount];
    }
}

-(void)commandCollectionFailed:(NSNotification*)ntf
{
    LCSCommandControllerCollection* sender = [ntf object];
    LCSCommandController* originalSender = [[ntf userInfo] objectForKey:LCSCommandControllerCollectionOriginalSenderKey];
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
    NSParameterAssert([activeControllers.controllers count] == 0);
    
    controller.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeGatherInformation:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:activeControllers];
    
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
    
    if (![self verifyDiskInformation:sourceInfoCtl.result withChecksum:sourceChecksum]) {
        return;
    }
    if (![self verifyDiskInformation:targetInfoCtl.result withChecksum:targetChecksum]) {
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
                                             selector:@selector(completeBlockCopy:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    ctl.title = [NSString localizedStringWithFormat:@"Block copy"];
    [activeControllers addController:ctl];
}

-(void)completeBlockCopy:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
    
    needsSourceRemount = NO;
    
    controller.progressMessage = [NSString localizedStringWithFormat:@"Complete"];
    
    controller.state = LCSCommandStateFinished;
}

-(void)startSourceRemount
{
    controller.progressMessage = [NSString localizedStringWithFormat:@"Remounting source device"];
    
    LCSCommandController *ctl = [runner run:[LCSDiskMountCommand commandWithDevicePath:sourceDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeSourceRemount:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:ctl];
    ctl.title = [NSString localizedStringWithFormat:@"Remount source device"];
    [activeControllers addController:ctl];
}

-(void)completeSourceRemount:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:sender.state]
                                                  object:sender];
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
