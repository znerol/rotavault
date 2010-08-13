//
//  LCSVerifyDiskInfoChecksumOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSVerifyDiskInfoChecksumOperation.h"

@implementation LCSVerifyDiskInfoChecksumOperation
@synthesize diskinfo;
@synthesize checksum;
-(id)init
{
    self = [super init];
    diskinfo = [[NSNull null] retain];
    checksum = [[NSNull null] retain];
    return self;
}

-(void)dealloc
{
    [diskinfo release];
    [checksum release];
    [super dealloc];
}

-(void)execute
{
    /* calculate checksum and generate an error if appropriate */
}
@end
