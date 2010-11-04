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
        NSMutableDictionary *byDeviceNode = [NSMutableDictionary dictionaryWithCapacity:[raidListCommand.result count]];
        NSMutableDictionary *byMemberUUID = [NSMutableDictionary dictionaryWithCapacity:[raidListCommand.result count]];
        NSMutableDictionary *byMemberDeviceNode =
            [NSMutableDictionary dictionaryWithCapacity:[raidListCommand.result count]];
        
        for (NSDictionary* raidinfo in raidListCommand.result) {
            [byUUID setObject:raidinfo forKey:[raidinfo objectForKey:@"RAIDSetUUID"]];
            [byDeviceNode setObject:raidinfo forKey:[raidinfo objectForKey:@"DeviceNode"]];
            for (NSDictionary* memberinfo in [raidinfo objectForKey:@"RAIDSetMembers"]) {
                [byMemberUUID setObject:raidinfo forKey:[memberinfo objectForKey:@"RAIDMemberUUID"]];
                [byMemberDeviceNode setObject:raidinfo forKey:[memberinfo objectForKey:@"DeviceNode"]];                
            }
            
            if ([isNotOnline evaluateWithObject:raidinfo]) {
                expiryTimeout = shortTimeout;
            }
        }
        self.value = [NSDictionary dictionaryWithObjectsAndKeys:
                      byUUID, @"byRAIDSetUUID",
                      byDeviceNode, @"byRAIDSetDeviceNode",
                      byMemberUUID, @"byMemberUUID",
                      byMemberDeviceNode, @"byMemberDeviceNode",
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

- (void)performInstall
{
    self.state = LCSObserverStateInstalled;
}

- (void)performRemove
{
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
