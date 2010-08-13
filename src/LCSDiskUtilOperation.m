//
//  LCSDiskUtilOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskUtilOperation.h"


@implementation LCSListDisksOperation
-(void)taskBuildArguments
{
    self.extractKeyPath = @"AllDisks";
    self.arguments = [NSArray arrayWithObjects:@"list", @"-plist", nil];
    self.launchPath = @"/usr/sbin/diskutil";
}
@end

@implementation LCSInformationForDiskOperation
@synthesize device;
-(id)init
{
    self = [super init];
    device = [[NSNull null] retain];
    return self;
}

-(void)dealloc
{
    [device release];
    [super dealloc];
}

-(void)taskBuildArguments
{
    self.arguments = [NSArray arrayWithObjects:@"info", @"-plist", device, nil];
    self.launchPath = @"/usr/sbin/diskutil";
}
@end
