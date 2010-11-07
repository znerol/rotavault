//
//  LCSRotavaultVolumeChooserController.m
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultVolumeChooserController.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultSystemEnvironmentObserver.h"


@interface LCSRotavaultVolumeChooserController (Internal)
- (void)environmentChanged:(NSNotification*)ntf;
@end


@implementation LCSRotavaultVolumeChooserController
@synthesize disks;
@synthesize selectedDisks;

- (id)init
{
    LCSINIT_OR_RETURN_NIL([super initWithNibName:@"VolumeChooser" bundle:nil]);
    
    LCSRotavaultSystemEnvironmentObserver *obs =
        [LCSRotavaultSystemEnvironmentObserver defaultSystemEnvironmentObserver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(environmentChanged:)
                                                 name:LCSRotavaultSystemEnvironmentRefreshed
                                               object:obs];
    [obs refreshInBackgroundAndNotify];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)environmentChanged:(NSNotification*)ntf
{
    LCSRotavaultSystemEnvironmentObserver *obs = [ntf object];
    
    NSArray *volumes = [[obs.registry valueForKeyPath:@"diskinfo.byVolumeUUID"] allObjects];
    volumes = [volumes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"MountPoint != ''"]];
    NSMutableArray *newContents = [NSMutableArray arrayWithCapacity:[volumes count]];
    for (NSDictionary *volume in volumes) {
        BOOL israid = ([[NSNumber numberWithBool:YES] isEqualToNumber:[volume valueForKey:@"RAIDMaster"]] &&
                       [@"Mirror" isEqualToString:[volume valueForKey:@"RAIDSetLevelType"]]);
        
        NSString *diskLabel = [NSString stringWithFormat:@"Volume %@ (%@)", [volume objectForKey:@"VolumeName"],
                               [volume objectForKey:@"DeviceIdentifier"]];
        NSDictionary *newDisk = [NSDictionary dictionaryWithObjectsAndKeys:
                                 diskLabel, @"label",
                                 israid ? [NSImage imageNamed:@"RAID"] : [NSImage imageNamed:@"Disk"], @"image",
                                 [NSNumber numberWithBool:NO], @"isRAIDSlice",
                                 [volume objectForKey:@"DeviceIdentifier"], @"DeviceIdentifier",
                                 nil];
        [newContents addObject:newDisk];
        
        if (israid) {
            NSArray *members = [obs.registry valueForKeyPath:
                                [NSString stringWithFormat:@"appleraid.byRAIDSetDeviceIdentifier.%@.RAIDSetMembers",
                                 [volume valueForKey:@"DeviceIdentifier"]]];
            for (NSDictionary *member in members) {
                NSString *memberLabel = [NSString stringWithFormat:@"    Raid Slice %@ (%@)",
                                         [member objectForKey:@"RAIDSliceNumber"],
                                         [member objectForKey:@"DeviceIdentifier"]];
                NSDictionary *newMember = [NSDictionary dictionaryWithObjectsAndKeys:
                                           memberLabel, @"label",
                                           [NSImage imageNamed:@"Disk"], @"image",
                                           [NSNumber numberWithBool:YES], @"isRAIDSlice",
                                           [member objectForKey:@"DeviceIdentifier"], @"DeviceIdentifier",
                                           nil];
                [newContents addObject:newMember];
            }
        }
    }
    
    if ([newContents isEqual:self.disks]) {
        return;
    }
    
    self.disks = [[newContents copy] autorelease];
}
@end
