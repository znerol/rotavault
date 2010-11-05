//
//  LCSRotavaultVolumeChooserController.m
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultVolumeChooserController.h"
#import "LCSRotavaultSystemEnvironmentObserver.h"


@interface LCSRotavaultVolumeChooserController (Internal)
- (void)environmentChanged:(NSNotification*)ntf;
@end


@implementation LCSRotavaultVolumeChooserController
@synthesize disks;
@synthesize selectedDisks;

- (id)init
{
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
    
    NSArray *volumes = [[obs.registry valueForKeyPath:@"disks.byVolumeUUID"] allObjects];
    NSMutableArray *newContents = [NSMutableArray arrayWithCapacity:[volumes count]];
    for (NSDictionary *volume in volumes) {
        NSDictionary *newDisk = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [volume objectForKey:@"VolumeName"], @"label",
                                 [NSNull null], @"image",
                                 nil];
        [newContents addObject:newDisk];
    }
    
    self.disks = [[newContents copy] autorelease];
}
@end
