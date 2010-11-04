//
//  LCSAppleRAIDObserver.m
//  rotavault
//
//  Created by Lorenz Schori on 04.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSAppleRAIDObserver.h"
#import "LCSInitMacros.h"
#import "LCSAppleRAIDListCommand.h"
#import "LCSDiskArbitration.h"


@implementation LCSAppleRAIDObserver

- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    shortTimeout = 2;
    longTimeout = 10;
    
    return self;
}

- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [raidListCommand release];
    [super dealloc];
}

- (void)expireRaidList
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(expireRaidList) object:nil];
    self.state = LCSObserverStateStale;
}

- (void)invalidateRaidListCommand:(NSNotification*)ntf
{
    NSAssert(raidListCommand == [ntf object], @"Received unexpected notification");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:raidListCommand];
    
    NSTimeInterval expiryTimeout = longTimeout;
    NSPredicate *isNotOnline = [NSPredicate predicateWithFormat:@"RAIDSetStatus != 'Online'"];
    if (raidListCommand.exitState == LCSCommandStateFinished) {
        NSMutableDictionary *byUUID = [NSMutableDictionary dictionaryWithCapacity:[raidListCommand.result count]];
        NSMutableDictionary *byDeviceIdentifier = [NSMutableDictionary dictionaryWithCapacity:[raidListCommand.result count]];
        NSMutableDictionary *byMemberUUID = [NSMutableDictionary dictionaryWithCapacity:[raidListCommand.result count]];
        NSMutableDictionary *byMemberDeviceIdentifier =
            [NSMutableDictionary dictionaryWithCapacity:[raidListCommand.result count]];
        
        for (NSDictionary* raidinfo in raidListCommand.result) {
            /* prepare the dictionaries in order to be able to access the information using different paths */
            [byUUID setObject:raidinfo forKey:[raidinfo objectForKey:@"RAIDSetUUID"]];
            [byDeviceIdentifier setObject:raidinfo forKey:[raidinfo objectForKey:@"DeviceIdentifier"]];
            for (NSDictionary* memberinfo in [raidinfo objectForKey:@"RAIDSetMembers"]) {
                [byMemberUUID setObject:raidinfo forKey:[memberinfo objectForKey:@"RAIDMemberUUID"]];
                [byMemberDeviceIdentifier setObject:raidinfo forKey:[memberinfo objectForKey:@"DeviceIdentifier"]];                
            }
            
            /* We do more status updates if some raid device is rebuilding */
            if ([isNotOnline evaluateWithObject:raidinfo]) {
                expiryTimeout = shortTimeout;
            }
            
            /* 
             * DiskArbitration does not send a disk change notification when a raid set or the status of members change.
             * We work around that problem by comparing new values against former ones and send change notifications
             * for all disks in a raid-set whenever the status of the whole set changes.
             */
            NSString *oldstat = [self.value valueForKeyPath:
                                 [NSString stringWithFormat:@"byRAIDSetDeviceIdentifier.%@.RAIDSetStatus",
                                  [raidinfo objectForKey:@"DeviceIdentifier"]]];
            NSString *newstat = [raidinfo objectForKey:@"RAIDSetStatus"];
            if (![newstat isEqualToString:oldstat]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:LCSDiskDescriptionChangedNotification
                                                                    object:[raidinfo objectForKey:@"DeviceIdentifier"]];
                for (NSString *memberid in [raidinfo valueForKeyPath:@"RAIDSetMembers.DeviceIdentifier"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:LCSDiskDescriptionChangedNotification
                                                                        object:memberid];
                }
            }
        }
        
        self.value = [NSDictionary dictionaryWithObjectsAndKeys:
                      byUUID, @"byRAIDSetUUID",
                      byDeviceIdentifier, @"byRAIDSetDeviceIdentifier",
                      byMemberUUID, @"byMemberUUID",
                      byMemberDeviceIdentifier, @"byMemberDeviceIdentifier",
                      nil];
    }
    else {
        self.value = nil;
    }
    
    [raidListCommand autorelease];
    raidListCommand = nil;
    
    self.state = LCSObserverStateFresh;
    
    [self performSelector:@selector(expireRaidList) withObject:nil afterDelay:expiryTimeout];
}

- (void)diskChanged:(NSNotification*)ntf
{
    NSString *disk = [ntf object];
    if ([self validateNextState:LCSObserverStateStale] &&
        (self.value == nil ||
         [self.value valueForKeyPath:[NSString stringWithFormat:@"byRAIDSetDeviceIdentifier.%@", disk]] ||
         [self.value valueForKeyPath:[NSString stringWithFormat:@"byMemberDeviceIdentifier.%@", disk]])) {
        self.state = LCSObserverStateStale;
    }
}

- (void)diskAppeared:(NSNotification*)ntf
{
    if ([self validateNextState:LCSObserverStateStale]) {
        self.state = LCSObserverStateStale;
    }
}

- (void)diskDisappeared:(NSNotification*)ntf
{
    NSString *disk = [ntf object];
    if ([self validateNextState:LCSObserverStateStale] &&
        (self.value == nil ||
         [self.value valueForKeyPath:[NSString stringWithFormat:@"byRAIDSetDeviceIdentifier.%@", disk]] ||
         [self.value valueForKeyPath:[NSString stringWithFormat:@"byMemberDeviceIdentifier.%@", disk]])) {
        self.state = LCSObserverStateStale;
    }
}

- (void)performInstall
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(diskChanged:)
                                                 name:LCSDiskDescriptionChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(diskAppeared:)
                                                 name:LCSDiskAppearedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(diskDisappeared:)
                                                 name:LCSDiskDisappearedNotification
                                               object:nil];
    self.state = LCSObserverStateInstalled;
}

- (void)performRemove
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LCSDiskDescriptionChangedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LCSDiskAppearedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LCSDiskDisappearedNotification
                                                  object:nil];
    self.state = LCSObserverStateRemoved;
}

- (void)performStartRefresh
{
    if (raidListCommand != nil) {
        return;
    }

    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(expireRaidList) object:nil];
    self.state = LCSObserverStateRefreshing;
    
    raidListCommand = [LCSAppleRAIDListCommand command];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateRaidListCommand:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:raidListCommand];
    raidListCommand.title = [NSString localizedStringWithFormat:@"Retreiving information about Apple RAID devices."];
    
    [raidListCommand retain];
    [raidListCommand start];
}

@end
