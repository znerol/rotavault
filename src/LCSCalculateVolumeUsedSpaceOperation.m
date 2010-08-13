//
//  LCSCalculateVolumeUsedSpaceOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSCalculateVolumeUsedSpaceOperation.h"
@implementation LCSCalculateVolumeUsedSpaceOperation
@synthesize diskinfo;
@synthesize result;

- (id)init
{
    self = [super init];
    diskinfo = [[NSNull null] retain];
    result = [[NSNull null] retain];
    return self;
}

- (void)dealloc
{
    [diskinfo release];
    [result  release];
    [super dealloc];
}

- (void)execute
{
    uint64_t totalSize = [[diskinfo valueForKey:@"TotalSize"] unsignedLongLongValue];
    uint64_t freeSpace = [[diskinfo valueForKey:@"FreeSpace"] unsignedLongLongValue];

    /* source size in bytes */
    result = [[NSNumber alloc] initWithUnsignedLongLong:totalSize - freeSpace];
}
@end
