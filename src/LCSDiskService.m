//
//  LCSDiskService.m
//  rotavault
//
//  Created by Lorenz Schori on 21.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskService.h"


@implementation LCSDiskService

/**
 * Return a list of the unix name of all disks, partitions and slices
 */
- (NSArray*) listDisks
{
    NSTask* diskutil = [[NSTask alloc] init];
    [diskutil setLaunchPath:@"/usr/sbin/diskutil"];
    [diskutil setArguments:[[NSArray alloc] initWithObjects:
                            @"list", @"-plist", nil]];
    
    NSPipe* stdout = [NSPipe pipe];
    [diskutil setStandardOutput:[stdout fileHandleForWriting]];
    [diskutil launch];
    [diskutil waitUntilExit];
    
    NSData* data = [[stdout fileHandleForReading] availableData];
    
    NSPropertyListFormat format;
    NSString *error = [NSString string];
    NSDictionary *result =
    (NSDictionary*)[NSPropertyListSerialization
                    propertyListFromData:data
                    mutabilityOption:NSPropertyListImmutable
                    format:&format errorDescription:&error];
    return [result objectForKey:@"AllDisks"];
}

/**
 * Return a dictionary containing detailed information about one disk/partition
 */
- (NSDictionary*) diskInfo:(NSString*)identifier
{
    NSTask* diskutil = [[NSTask alloc] init];
    [diskutil setLaunchPath:@"/usr/sbin/diskutil"];
    [diskutil setArguments:[[NSArray alloc] initWithObjects:
                            @"info", @"-plist", identifier, nil]];
    
    NSPipe* stdout = [NSPipe pipe];
    [diskutil setStandardOutput:[stdout fileHandleForWriting]];
    [diskutil launch];
    [diskutil waitUntilExit];
    
    NSData* data = [[stdout fileHandleForReading] availableData];
    
    NSPropertyListFormat format;
    NSString *error = [NSString string];
    NSDictionary *result =
    (NSDictionary*)[NSPropertyListSerialization
                    propertyListFromData:data
                    mutabilityOption:NSPropertyListImmutable
                    format:&format errorDescription:&error];
    return result;
}

/**
 * Return detailed information of all mounted/mountable volumes (with an UUID)
 */
- (NSArray*) listVolumes
{
    NSEnumerator *allDisks = [[self listDisks] objectEnumerator];
    NSString *identifier;
    NSDictionary *info;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    while (identifier = [allDisks nextObject]) {
        info = [self diskInfo:identifier];
        if ([info objectForKey:@"VolumeUUID"] == nil) {
            continue;
        }
        [result addObject:info];
    }
    return [NSArray arrayWithArray:result];
}

@end
