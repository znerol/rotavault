//
//  LCSDiskService.m
//  rotavault
//
//  Created by Lorenz Schori on 21.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskService.h"
#import "LCSPlistTaskOutputHandler.h"


@implementation LCSDiskService

/**
 * Return a list of the unix name of all disks, partitions and slices
 */
- (NSArray*) listDisks
{
    NSDictionary* results = [LCSPlistTaskOutputHandler
                             resultsFromTerminatedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                             arguments:[NSArray arrayWithObjects: @"list", @"-plist", nil]];
    return [results objectForKey:@"AllDisks"];
}

/**
 * Return a dictionary containing detailed information about one disk/partition
 */
- (NSDictionary*) diskInfo:(NSString*)identifier
{
    NSDictionary* results = [LCSPlistTaskOutputHandler
                             resultsFromTerminatedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                             arguments:[NSArray arrayWithObjects: @"info", @"-plist",identifier, nil]];
    return results;
}

/**
 * Return detailed information of all mounted/mountable volumes (with an UUID)
 */
- (NSArray*) listVolumes
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *diskList = [self listDisks];
    
    for (NSString* identifier in diskList) {
        NSDictionary *info = [self diskInfo:identifier];
        if ([info objectForKey:@"VolumeUUID"] == nil) {
            continue;
        }
        [result addObject:info];
    }
    return [NSArray arrayWithArray:result];
}

@end
