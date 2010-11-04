//
//  LCSDiskInfoObserver.m
//  rotavault
//
//  Created by Lorenz Schori on 03.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskInfoObserver.h"
#import "LCSInitMacros.h"
#import "LCSDiskInfoCommand.h"
#import "LCSDiskArbitration.h"


@interface LCSDiskInfoObserver (Internal)
- (int)startPendingDiskInfoCommands;
- (void)invalidateDiskInfoCommand:(NSNotification*)ntf;
- (void)diskChanged:(NSNotification*)ntf;
- (void)diskAppeared:(NSNotification*)ntf;
- (void)diskDisappeared:(NSNotification*)ntf;
@end


@implementation LCSDiskInfoObserver
+ (LCSDiskInfoObserver*)observer
{
    return [[[LCSDiskInfoObserver alloc] init] autorelease];
}

- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    dirty = [[NSMutableSet alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(dirty);
    commands = [[NSMutableDictionary alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(commands);
    disks = [[NSMutableDictionary alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(disks);
    
    return self;
}

- (void)dealloc
{
    [dirty release];
    [commands release];
    [disks release];
    [super dealloc];
}

- (void)invalidateDiskInfoCommand:(NSNotification*)ntf
{
    LCSCommand *sender = [ntf object];
    NSArray *keys = [commands allKeysForObject:sender];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:sender];
    
    NSAssert([keys count] == 1, @"One key for each command required");
    NSString *bsdname = [keys objectAtIndex:0];
    
    if (sender.exitState == LCSCommandStateFinished) {
        [disks setObject:sender.result forKey:bsdname];
    }
    else {
        [disks removeObjectForKey:bsdname];
    }
    
    /* Rebuild value dictionary */
    NSMutableDictionary *byDeviceIdentifier = [NSMutableDictionary dictionaryWithCapacity:[disks count]];
    NSMutableDictionary *byVolumeUUID = [NSMutableDictionary dictionaryWithCapacity:[disks count]];
    NSMutableDictionary *byMountPoint = [NSMutableDictionary dictionaryWithCapacity:[disks count]];
    for (NSString* devid in disks) {
        NSDictionary* disk = [disks objectForKey:devid];
        [byDeviceIdentifier setObject:disk forKey:devid];
        
        NSString *voluuid = [disk objectForKey:@"VolumeUUID"];
        if (voluuid) {
            [byVolumeUUID setObject:disk forKey:voluuid];
        }
        
        NSString *mountpt = [disk objectForKey:@"MountPoint"];
        if (mountpt) {
            [byMountPoint setObject:disk forKey:mountpt];
        }
    }
    
    self.value = [NSDictionary dictionaryWithObjectsAndKeys:
                  byDeviceIdentifier, @"byDeviceIdentifier",
                  byVolumeUUID, @"byVolumeUUID",
                  byMountPoint, @"byMountPoint",
                  nil];
    
    /* remove and release sender */
    [commands removeObjectForKey:bsdname];
    
    if (autorefresh) {
        [self startPendingDiskInfoCommands];
    }
    
    if ([commands count] == 0) {
        self.state = LCSObserverStateFresh;
    }
}

- (void)diskChanged:(NSNotification*)ntf
{
    [dirty addObject:[ntf object]];
    if ([self validateNextState:LCSObserverStateStale]) {
        self.state = LCSObserverStateStale;
    }
}

- (void)diskAppeared:(NSNotification*)ntf
{
    [dirty addObject:[ntf object]];
    if ([self validateNextState:LCSObserverStateStale]) {
        self.state = LCSObserverStateStale;
    }
}

- (void)diskDisappeared:(NSNotification*)ntf
{
    [dirty removeObject:[ntf object]];
    LCSCommand *cmd = [commands objectForKey:[ntf object]];
    if (cmd) {
        [cmd cancel];
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

- (int)startPendingDiskInfoCommands
{
    NSSet *dirtyDisks = [[dirty copy] autorelease];
    int count = 0;
    
    for (NSString *bsdname in dirtyDisks) {
        if ([commands objectForKey:bsdname]) {
            continue;
        }
        
        LCSCommand* cmd = [LCSDiskInfoCommand commandWithDevicePath:bsdname];
        cmd.title = [NSString localizedStringWithFormat:@"Retreiving information about Disk %@", bsdname];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(invalidateDiskInfoCommand:)
                                                     name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                   object:cmd];
        
        [commands setObject:cmd forKey:bsdname];
        [dirty removeObject:bsdname];
        
        [cmd start];
        count++;
    }
    return count;
}

- (void)performStartRefresh
{
    int count = [self startPendingDiskInfoCommands];
    if (count > 0) {
        self.state = LCSObserverStateRefreshing;
    }
}
@end
