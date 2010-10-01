//
//  LCSCalculateVolumeUsedSpaceOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSCalculateVolumeUsedSpaceOperation.h"
#import "LCSInitMacros.h"


@implementation LCSCalculateVolumeUsedSpaceOperation
@synthesize diskinfo;
@synthesize result;

- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    diskinfo = [[NSNull null] retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(diskinfo);

    result = [[NSNull null] retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(result);
    
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
